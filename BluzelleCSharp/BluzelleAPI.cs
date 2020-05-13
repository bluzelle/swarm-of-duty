using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using BluzelleCSharp.Models;
using Newtonsoft.Json.Linq;

namespace BluzelleCSharp
{
    public class BluzelleAPI : Cosmos
    {
        public const int BlockTimeInSeconds = 5;

        public BluzelleAPI(string namespaceId, string mnemonic, string address, string chainId = "bluzelle",
            string endpoint = "http://testnet.public.bluzelle.com:1317") : base(namespaceId, mnemonic, address, chainId,
            endpoint)
        {
            
            var r4esult = TxGetNShortestLease(1, new GasInfo {GasPrice = 10}).Result;
            Console.WriteLine(1);
        }

        private async void Init()
        {
        }

        public async Task TestRun()
        {
            //var res = GetAccount(sessionAddress).Result;
            //Console.WriteLine(res.Address);
        }

        #region REST API Queries

        public async Task<string> Read(string id, bool prove = false)
        {
            var data = await Query<JObject>(
                $"{CrudServicePrefix}/{(prove ? "p" : "")}read/{NamespaceId}/{UrlEncoder.Default.Encode(id)}");
            if (data == null) throw new KeyNotFoundException();
            return (string) data["value"];
        }

        public async Task<bool> HasKey(string id)
        {
            return (bool) (await Query<JObject>($"{CrudServicePrefix}/has/{NamespaceId}/{id}"))["has"];
        }

        public async Task<List<string>> Keys()
        {
            return (await Query<JObject>($"{CrudServicePrefix}/keys/{NamespaceId}"))
                ["keys"]
                ?.ToObject<List<string>>();
        }

        public async Task<int> Count()
        {
            return (int) (await Query<JObject>($"{CrudServicePrefix}/count/{NamespaceId}"))["count"];
        }

        private Dictionary<string, string> PostprocessKeyVal(JToken data)
        {
            return data.Aggregate(
                new Dictionary<string, string>(),
                (cur, next) =>
                {
                    cur.Add(((string) next["key"])!, (string) next["value"]);
                    return cur;
                });
        }

        public async Task<Dictionary<string, string>> GetKeyValues()
        {
            var res = await Query<JObject>($"{CrudServicePrefix}/keyvalues/{NamespaceId}");
            return PostprocessKeyVal(res["keyvalues"] ?? throw new Exception("Failed to get KV list"));
        }

        public async Task<int> GetLease(string key)
        {
            return (int) (await Query<JObject>($"{CrudServicePrefix}/getlease/{NamespaceId}/{key}"))["lease"]
                   * BlockTimeInSeconds;
        }

        private Dictionary<string, int> PostprocessGNSL(JToken data)
        {
             return data.Aggregate(
                 new Dictionary<string, int>(),
                 (cur, next) =>
                 {
                     cur.Add(((string) next["key"])!, (int) next["lease"] * BlockTimeInSeconds);
                     return cur;
                 });
        }
        
        public async Task<Dictionary<string, int>> GetNShortestLease(int n)
        {
            var res = await Query<JObject>($"{CrudServicePrefix}/getnshortestlease/{NamespaceId}/{n}");
            return PostprocessGNSL(res["keyleases"] ?? throw new Exception("Failed to get leases list"));
        }

        public async Task<string> GetVersion()
        {
            return (string) Query("node_info").Result["application_version"]?["version"];
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

        public async Task UpdateMany(JArray data, GasInfo gasInfo = null)
        {
            var res = await SendTransaction(new JObject
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

        public async Task<Dictionary<string, int>> TxGetNShortestLease(int n, GasInfo gasInfo = null)
        {
            if(n < 0) throw new Exception("Invalid N");
            var res = await SendTransaction(new JObject
            {
                ["N"] = n
            }, "post", "getnshortestlease", gasInfo);
            return PostprocessGNSL(res["keyleases"] ?? throw new Exception("Failed to get leases list"));
        }
        
        #endregion
    }
}