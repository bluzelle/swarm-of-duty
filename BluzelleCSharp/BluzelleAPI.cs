using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BluzelleCSharp.Models;
using Newtonsoft.Json.Linq;
using RestSharp;

namespace BluzelleCSharp
{
    public class BluzelleAPI : Cosmos
    {
        public const int BlockTimeInSeconds = 5;

        public BluzelleAPI(string namespaceId, string mnemonic, string address, string chainId = "bluzelle", string endpoint = "http://testnet.public.bluzelle.com:1317") : base(namespaceId, mnemonic, address, chainId, endpoint)
        {
            var result = SendTransaction(new JObject {
                ["Key"] = "a"
            }, "post", "read", new GasInfo{GasPrice = 10}).Result;
            
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

        public async Task<bool> HasKey(string id)
        {
            return (bool) (await Query<JObject>($"{CrudServicePrefix}/has/{NamespaceId}/{id}"))["has"];
        }

        public async Task<List<string>> ListKeys()
        {
            return (await Query<JObject>($"{CrudServicePrefix}/keys/{NamespaceId}"))["keys"]
                ?.ToObject<List<string>>();
        }
        public async Task<int> CountKeys()
        {
            return (int) (await Query<JObject>($"{CrudServicePrefix}/count/{NamespaceId}"))["count"];
        }

        public async Task<Dictionary<string, string>> GetKeyVal()
        {
            var res = (await Query<JObject>($"{CrudServicePrefix}/keyvalues/{NamespaceId}"));
            return (res["keyvalues"] ?? throw new Exception("Failed to get KV list"))
                .Aggregate(
                    new Dictionary<string, string>(),
                    (cur, next) =>
                    {
                        cur.Add(((string) next["key"])!, (string) next["value"]);
                        return cur;
                    });
        }

        public async Task<int> GetLease(string key)
        {
            return (int) (await Query<JObject>($"{CrudServicePrefix}/getlease/{NamespaceId}/{key}"))["lease"] 
                   * BlockTimeInSeconds;
        }
        
        public async Task<Dictionary<string, int>> GetNShortestLease(int n)
        {
            var res = await Query<JObject>($"{CrudServicePrefix}/getnshortestlease/{NamespaceId}/{n}");
            return (res["keyleases"] ?? throw new Exception("Failed to get leases list"))
                .Aggregate(
                    new Dictionary<string, int>(),
                    (cur, next) =>
                    {
                        cur.Add(((string) next["key"])!, (int) next["lease"] * BlockTimeInSeconds);
                        return cur;
                    });
        }

        public async Task<string> GetVersion()
        {
            return (string) Query("node_info").Result["application_version"]?["version"];
        }
    }

    internal class InitializationException : Exception { }
}
