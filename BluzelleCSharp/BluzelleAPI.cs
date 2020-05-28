using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Encodings.Web;
using System.Threading;
using System.Threading.Tasks;
using BluzelleCSharp.Models;
using Newtonsoft.Json.Linq;

namespace BluzelleCSharp
{
    /**
     * <summary>
     * API for bluzelle database.
     * Most of operations are available in transaction (methods have 'tx' prefix) and query styles
     * </summary>
     */
    public class BluzelleApi : Cosmos
    {
        public const int BlockTimeInSeconds = 5;

        /**
         * <summary>Initializes Bluzelle Database API</summary>
         * <param name="namespaceId">Bluzelle Database Namespace ID</param>
         * <param name="mnemonic">Mnemonic for account in BIP39</param>
         * <param name="address">Account address in Cosmos format. It'll be verified over given mnemonic</param>
         * <param name="chainId">Database chain ID. For Bluzelle network it equals to "bluzelle"</param>
         * <param name="endpoint">REST API endpoint including protocol and port</param>
         */
        public BluzelleApi(string namespaceId, string mnemonic, string address, string chainId = "bluzelle",
            string endpoint = "http://testnet.public.bluzelle.com:1317") : base(namespaceId, mnemonic, address, chainId,
            endpoint)
        {
        }

        #region REST API Queries

        /**
         * <summary>Read value of key <paramref name="id"/></summary>
         * <param name="id">DB key string</param>
         * <param name="prove">Use "pread" of "read" operation</param>
         * <returns>String value</returns>
         */
        public async Task<string> Read(string id, bool prove = false)
        {
            var data = await Query<JObject>(
                $"{CrudServicePrefix}/{(prove ? "p" : "")}read/{NamespaceId}/{UrlEncoder.Default.Encode(id)}");
            if (data == null) throw new KeyNotFoundException();
            return (string) data["value"];
        }

        /**
         * <summary>Check existence of key <paramref name="id"/></summary>
         * <param name="id">DB key string</param>
         * <returns>true if key exists in current namespace</returns>
         */
        public async Task<bool> HasKey(string id)
        {
            return (bool) (await Query<JObject>($"{CrudServicePrefix}/has/{NamespaceId}/{id}"))["has"];
        }

        /**
         * <summary>Retrieve list of keys in current namespace</summary>
         * <returns>List of strings with keys available</returns>
         */
        public async Task<List<string>> Keys()
        {
            return (await Query<JObject>($"{CrudServicePrefix}/keys/{NamespaceId}"))
                ["keys"]
                ?.ToObject<List<string>>();
        }

        /**
         * <summary>Get keys count in current namespace</summary>
         */
        public async Task<int> Count()
        {
            return (int) (await Query<JObject>($"{CrudServicePrefix}/count/{NamespaceId}"))["count"];
        }
        
        /**
         * <summary>Get all data in Key-Value style from this namespace</summary>
         * <returns>Dictionary contains keys and values</returns>
         */
        public async Task<Dictionary<string, string>> GetKeyValues()
        {
            var res = await Query<JObject>($"{CrudServicePrefix}/keyvalues/{NamespaceId}");
            return PostprocessKeyVal(res["keyvalues"] ?? throw new Exception("Failed to get KV list"));
        }

        /**
         * <summary>Get lease time of key <paramref name="key"/></summary>
         * <param name="key">DB key string</param>
         * <returns>Lease time in seconds</returns>
         */
        public async Task<int> GetLease(string key)
        {
            return (int) (await Query<JObject>($"{CrudServicePrefix}/getlease/{NamespaceId}/{key}"))["lease"]
                   * BlockTimeInSeconds;
        }

        /**
         * <summary>Get N shortest leases in current namespace</summary>
         * <param name="n">Leases to return</param>
         * <returns>List containing shortest leases in ascending order with KeyValuePair of keys and its' leases in seconds</returns>
         */
        public async Task<List<KeyValuePair<string, int>>> GetNShortestLease(int n)
        {
            var res = await Query<JObject>($"{CrudServicePrefix}/getnshortestleases/{NamespaceId}/{n}");
            return PostprocessNShortestLeases(res["keyleases"] ?? throw new Exception("Failed to get leases list"));
        }

        public async Task<string> GetVersion()
        {
            return (string) (await Query("node_info"))["application_version"]?["version"];
        }

        #endregion

        #region Transaction Queries

        public async Task Create(string key, string value, LeaseInfo leaseInfo, GasInfo gasInfo = null)
        {
            await SendTransaction(new JObject
            {
                ["Key"] = key,
                ["Value"] = value,
                ["Lease"] = leaseInfo.Value
            }, "post", "create", gasInfo);
        }

        public async Task Update(string key, string value, LeaseInfo leaseInfo, GasInfo gasInfo = null)
        {
            await SendTransaction(new JObject
            {
                ["Key"] = key,
                ["Value"] = value,
                ["Lease"] = leaseInfo.Value
            }, "post", "update", gasInfo);
        }

        private async Task UpdateMany(JArray data, GasInfo gasInfo = null)
        {
            await SendTransaction(new JObject
            {
                ["KeyValues"] = data
            }, "post", "multiupdate", gasInfo);
        }

        public async Task UpdateMany(Dictionary<string, string> data, GasInfo gasInfo = null)
        {
            await UpdateMany(data.Aggregate(
                new JArray(),
                (cur, next) =>
                {
                    cur.Add(new JObject
                    {
                        ["key"] = next.Key,
                        ["value"] = next.Value
                    });
                    return cur;
                }), gasInfo);
        }

        public async Task Delete(string key, GasInfo gasInfo = null)
        {
            await SendTransaction(new JObject
            {
                ["Key"] = key
            }, "delete", "delete", gasInfo);
        }

        public async Task DeleteAll(GasInfo gasInfo = null)
        {
            await SendTransaction("post", "deleteall", gasInfo);
        }

        public async Task Rename(string key, string newKey, GasInfo gasInfo = null)
        {
            await SendTransaction(new JObject
            {
                ["Key"] = key,
                ["NewKey"] = newKey
            }, "post", "rename", gasInfo);
        }

        public async Task Renew(string key, LeaseInfo leaseInfo, GasInfo gasInfo = null)
        {
            await SendTransaction(new JObject
            {
                ["Key"] = key,
                ["Lease"] = leaseInfo.Value
            }, "post", "renewlease", gasInfo);
        }

        public async Task RenewAll(LeaseInfo leaseInfo, GasInfo gasInfo = null)
        {
            await SendTransaction(new JObject
            {
                ["Lease"] = leaseInfo.Value
            }, "post", "renewleaseall", gasInfo);
        }

        public async Task<string> TxRead(string key, GasInfo gasInfo = null)
        {
            return (string) (await SendTransaction(new JObject
            {
                ["Key"] = key
            }, "post", "read", gasInfo))["value"];
        }

        public async Task<bool> TxHas(string key, GasInfo gasInfo = null)
        {
            return (bool) (await SendTransaction(new JObject
            {
                ["Key"] = key
            }, "post", "has", gasInfo))["has"];
        }

        public async Task<List<string>> TxKeys(GasInfo gasInfo = null)
        {
            return (await SendTransaction("post", "keys", gasInfo))
                ["keys"]
                ?.ToObject<List<string>>();
        }

        public async Task<int> TxCount(GasInfo gasInfo = null)
        {
            return (int) (await SendTransaction("post", "count", gasInfo))["count"];
        }

        public async Task<Dictionary<string, string>> TxGetKeyValues(GasInfo gasInfo = null)
        {
            var data = await SendTransaction("post", "keyvalues", gasInfo);
            return PostprocessKeyVal(data["keyvalues"]);
        }

        public async Task<int> TxGetLease(string key, GasInfo gasInfo = null)
        {
            return (int) (await SendTransaction(new JObject
            {
                ["Key"] = key
            }, "post", "getlease", gasInfo))["lease"] * BlockTimeInSeconds;
        }

        public async Task<List<KeyValuePair<string, int>>> TxGetNShortestLease(int n, GasInfo gasInfo = null)
        {
            if (n < 0) throw new Exception("Invalid N");
            var res = await SendTransaction(new JObject
            {
                ["N"] = $"{n}"
            }, "post", "getnshortestleases", gasInfo);
            return PostprocessNShortestLeases(res["keyleases"] ?? throw new Exception("Failed to get leases list"));
        }

        #endregion

        #region Utilitary functions
        /**
         * <summary>Function for converting JSON response of KeyValue command into C# native dictionary</summary>
         * <param name="data">JSON array of objects with "key" and "value" fields</param>
         * <returns>Dictionary contains keys and values</returns>
         */
        private static Dictionary<string, string> PostprocessKeyVal(JToken data)
        {
            return data.Aggregate(
                new Dictionary<string, string>(),
                (cur, next) =>
                {
                    cur.Add(((string) next["key"])!, (string) next["value"]);
                    return cur;
                });
        }
        
        /**
         * <summary>Function for converting JSON response of N-shortest-leases command into C# native list with KeyValues</summary>
         * <param name="data">JSON array of objects with "key" and "lease" fields</param>
         * <returns>List containing shortest leases in ascending order with KeyValuePair of keys and its' leases in seconds</returns>
         */
        private static List<KeyValuePair<string, int>> PostprocessNShortestLeases(JToken data)
        {
            return data.Aggregate(
                new List<KeyValuePair<string, int>>(),
                (cur, next) =>
                {
                    cur.Add(new KeyValuePair<string, int>(
                        (string) next["key"],
                        (int) next["lease"] * BlockTimeInSeconds)
                    );
                    return cur;
                });
        }

        #endregion
    }
}