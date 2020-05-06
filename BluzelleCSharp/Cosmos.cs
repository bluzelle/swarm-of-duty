using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using BluzelleCSharp.Models;
using NBitcoin;
using NBitcoin.Crypto;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using RestSharp;
using RestSharp.Serializers.NewtonsoftJson;

namespace BluzelleCSharp
{
    public class Cosmos
    {
        protected const string SvfErrorMessage = "signature verification failed";
        
        protected const string CrudServicePrefix = "crud";
        protected const string TxServicePrefix = "txs";

        private const string Bip32Path = "m/44'/118'/0'/0/0";
        private const string Bech32Prefix = "bluzelle";
        public const string TokenName = "ubnt";
        public const int RetryInterval = 1000;
        public const int MaxRetries = 10;
        public string ChainId;
        protected string Endpoint;

        protected string NamespaceId;

        protected RestClient restClient;

        protected int sessionAccount = 0;
        protected string sessionAddress;
        protected Key sessionPk;
        protected int sessionSequence;

        public Cosmos(
            string namespaceId,
            string mnemonic,
            string address = null,
            string chainId = "bluzelle",
            string endpoint = "http://testnet.public.bluzelle.com:1317")
        {
            ChainId = chainId;
            NamespaceId = namespaceId;
            Endpoint = endpoint;
            sessionPk = MnemonicToPrivateKey(mnemonic);
            sessionAddress = string.IsNullOrEmpty(address) ? GetAddress(sessionPk.PubKey) : address;

            restClient = new RestClient(Endpoint);
            restClient.UseNewtonsoftJson(new JsonSerializerSettings
            {
                ContractResolver = new DefaultContractResolver
                {
                    NamingStrategy = new SnakeCaseNamingStrategy()
                },
                NullValueHandling = NullValueHandling.Ignore
            });
        }

        protected static Key MnemonicToPrivateKey(string mnemonic)
        {
            return new Mnemonic(mnemonic, Wordlist.English).DeriveExtKey().Derive(new KeyPath(Bip32Path)).PrivateKey;
        }

        protected static string GetAddress(PubKey key)
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

        public async Task<JObject> SendTransaction(JObject data, string type, string cmd, GasInfo gasInfo = null)
        {
            data.Merge(new JObject
            {
                ["BaseReq"] = new JObject {["from"] = sessionAddress, ["chain_id"] = ChainId},
                ["UUID"] = NamespaceId,
                ["Owner"] = sessionAddress
            });
            data.Merge(gasInfo);

            var methodValid = Enum.TryParse<Method>(type, true, out var httpMethod);
            if (!methodValid) throw new Exception($"HTTP method {type} is unsupported");

            var request = new RestRequest($"{CrudServicePrefix}/{cmd}", httpMethod, DataFormat.Json)
                .AddParameter("application/x-www-form-urlencoded", data, ParameterType.RequestBody);

            var tx = restClient.PostAsync<JObject>(request).Result;

            gasInfo?.UpdateTransaction(tx);

            tx["value"]!["memo"] = Utils.MakeRandomString(32);
            tx["value"]!["signature"] = JObject.FromObject(SignTransaction(tx));
            tx["value"]!["signatures"] = new JArray {tx["value"]["signature"]!};

            var requestBody = new JObject
            {
                ["tx"] = tx,
                ["mode"] = "block",
                ["headers"] = new JObject {["Content-type"] = "application/x-www-form-urlencoded"}
            };
            request = new RestRequest($"{TxServicePrefix}", httpMethod, DataFormat.Json)
                .AddParameter("application/x-www-form-urlencoded", requestBody, ParameterType.RequestBody);

            var res = await restClient.PostAsync<JObject>(request);

            if (res.ContainsKey("code"))
            {
                if (res["raw_log"]!.ToString().Contains(SvfErrorMessage))
                {
                }
                else
                {
                    throw new TransactionExecutionException(Utils.ExtractErrorFromMessage((string) res["raw_log"]));
                }
            }
            else
            {
                sessionSequence++;
                return res["data"]! as JObject;
            }

            return null;
        }

        private Signature SignTransaction(JObject data)
        {
            var str = JsonConvert.SerializeObject(new JObject
            {
                ["account_number"] = sessionAccount.ToString(),
                ["chain_id"] = ChainId,
                ["fee"] = Utils.SortJObject(data["value"]!["fee"]),
                ["memo"] = data["value"]!["memo"],
                ["msgs"] = Utils.SortJObject(data["value"]["msg"]),
                ["sequence"] = sessionSequence.ToString()
            });

            // Like sanitize_string in blzjs - encode utf8 '&', '>' and '<'
            str = str.Aggregate("", (acc, x) =>
                acc + (new[] {'&', '>', '<'}.Contains(x) ? $"\\u00{(int) x:X}" : $"{x}"));

            var hash = SHA256.Create().ComputeHash(Encoding.UTF8.GetBytes(str));

            // Create signature and remove first byte when encoding base64, because SignCompact returns header+R+S
            var signature = Convert.ToBase64String(
                sessionPk.SignCompact(new uint256(hash), false),
                1, 64);

            return new Signature(
                sessionPk,
                signature,
                sessionAccount.ToString(),
                sessionSequence.ToString());
        }
    }
}