using System;
using System.IO.Compression;
using System.Linq;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using BluzelleCSharp.Models;
using NBitcoin;
using NBitcoin.Crypto;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using RestSharp;
using RestSharp.Authenticators;
using RestSharp.Serializers.NewtonsoftJson;

namespace BluzelleCSharp
{
    public class Cosmos
    {
        protected const string CrudServicePrefix = "crud";

        private const string Bip32Path = "m/44'/118'/0'/0/0";
        private const string Bech32Prefix = "bluzelle";
        public const string TokenName = "ubnt";
        public const int RetryInterval = 1000;
        public const int MaxRetries = 10;

        protected RestClient restClient;

        protected string sessionAccount = "0";
        protected string sessionSequence;   
        protected string sessionAddress;   
        protected Key sessionPk;

        protected string NamespaceId;
        protected string Endpoint;
        public string ChainId;
        
        public Cosmos(
            string namespaceId,
            string mnemonic,
            string address=null,
            string chainId="bluzelle",
            string endpoint="http://testnet.public.bluzelle.com:1317")
        {
            ChainId = chainId;
            NamespaceId = namespaceId;
            Endpoint = endpoint;
            sessionPk = MnemonicToPrivateKey(mnemonic);
            sessionAddress = string.IsNullOrEmpty(address) ? GetAddress(sessionPk.PubKey) : address;

            restClient = new RestClient(Endpoint);
            restClient.UseNewtonsoftJson(new JsonSerializerSettings
            {
                ContractResolver =  new DefaultContractResolver
                {
                    NamingStrategy = new SnakeCaseNamingStrategy()
                },
                NullValueHandling = NullValueHandling.Ignore
            });

            var result = SendTransaction(new JObject {
                ["Key"] = "a"
            }, "post", "read", new GasInfo(0, 0, 0)).Result;
        }

        protected static Key MnemonicToPrivateKey(string mnemonic)
        {
            return new Mnemonic(mnemonic, Wordlist.English).DeriveExtKey().Derive(new KeyPath(Bip32Path)).PrivateKey;
        }

        protected  static string GetAddress(PubKey key)
        {
            var z = Hashes.SHA256(key.ToBytes());
            return new Bech32(Bech32Prefix).Encode(Hashes.RIPEMD160(z, z.Length));
        }

        public async Task<T> Query<T>(string query)
        {
            return (await restClient.GetAsync<Responce<T>>(
                new RestRequest(UrlEncoder.Default.Encode(query), DataFormat.Json))).Result;
        }
        
        public async Task<JObject> Query(string query)
        {
            return await restClient.GetAsync<JObject>(
                new RestRequest(UrlEncoder.Default.Encode(query), DataFormat.Json));
        }

        public async Task<int> SendTransaction(JObject data, string type, string cmd, GasInfo gasInfo=null)
        {
            data.Merge(new JObject
            {
                ["BaseReq"] = new JObject {["from"] = sessionAddress, ["chain_id"] = ChainId},
                ["UUID"] = NamespaceId,
                ["Owner"] = sessionAddress,
            });
            data.Merge(gasInfo);
            
            var methodValid = Enum.TryParse<Method>(type, true, out var httpMethod);
            if(!methodValid) throw new Exception($"HTTP method {type} is unsupported");

            var request = new RestRequest($"{CrudServicePrefix}/{cmd}", httpMethod, DataFormat.Json)
                .AddParameter("application/x-www-form-urlencoded", data, ParameterType.RequestBody);

            var tx = restClient.PostAsync<JObject>(request).Result;
            
            gasInfo?.UpdateTransaction(tx);

            // tx["value"]!["memo"] = Utils.MakeRandomString(32);
            // tx["value"]!["signature"] = JObject.FromObject(SignTransaction(tx));
            // tx["value"]!["signatures"] = new JArray {tx["value"]["signature"]!};
            
            
            
            return 0;
        }

        
        
    }
}