using System;
using System.IO.Compression;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using BluzelleCSharp.Models;
using NBitcoin;
using NBitcoin.Crypto;
using NBitcoin.Secp256k1;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using RestSharp;
using RestSharp.Authenticators;
using RestSharp.Serializers.NewtonsoftJson;
using Secp256k1Net;
using SHA256 = System.Security.Cryptography.SHA256;

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

            tx["value"]!["memo"] = Utils.MakeRandomString(32);
            tx["value"]!["signature"] = JObject.FromObject(SignTransaction(tx));
            tx["value"]!["signatures"] = new JArray {tx["value"]["signature"]!};
            
            return 0;
        }

        private Signature SignTransaction(JObject data)
        {
            var str = JsonConvert.SerializeObject(new JObject
            {
                ["account_number"] = sessionAccount,
                ["chain_id"] = ChainId ,
                ["memo"] = data["value"]!["memo"],
                ["sequence"] = sessionSequence,
                ["msgs"] = Utils.SortJObject(data["value"]["msg"]),
                ["fee"] =  Utils.SortJObject(data["value"]["fee"])
            }); 

            str = JsonConvert.ToString(str, '\"', StringEscapeHandling.EscapeHtml);
            
            var a = Encoding.UTF8.GetBytes(str);
            var hash = SHA256.Create().ComputeHash(a);
            var signature = Convert.ToBase64String(
                sessionPk.SignCompact(new uint256(hash)), 
                1, 64);
            
            return new Signature(
                sessionPk, 
                signature, 
                sessionAccount, 
                sessionSequence);
        }

        /*
         * {
  "type": "cosmos-sdk/StdTx",
  "value": {
    "msg": [
      {
        "type": "crud/read",
        "value": {
          "UUID": "7f346254-2024-496f-bfa3-572a2e87ebd2",
          "Key": "a",
          "Owner": "bluzelle1upsfjftremwgxz3gfy0wf3xgvwpymqx754ssu9"
        }
      }
    ],
    "fee": {
      "amount": [],
      "gas": "200000"
    },
    "signatures": null,
    "memo": ""
  }
}










{
  "msg": [
    {
      "type": "crud/read",
      "value": {
        "UUID": "7f346254-2024-496f-bfa3-572a2e87ebd2",
        "Key": "a",
        "Owner": "bluzelle1upsfjftremwgxz3gfy0wf3xgvwpymqx754ssu9"
      }
    }
  ],
  "fee": {
    "amount": [
      {
        "denom": "ubnt",
        "amount": "0"
      }
    ],
    "gas": "0"
  },
  "signatures": null,
  "memo": "System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]System.Linq.Enumerable+AppendPrepend1Iterator`1[System.Char]"
}



{
  "type": "cosmos-sdk/StdTx",
  "value": {
    "msg": [
      {
        "type": "crud/read",
        "value": {
          "UUID": "7f346254-2024-496f-bfa3-572a2e87ebd2",
          "Key": "a",
          "Owner": "bluzelle1upsfjftremwgxz3gfy0wf3xgvwpymqx754ssu9"
        }
      }
    ],
    "fee": {
      "amount": [
        {
          "denom": "ubnt",
          "amount": "0"
        }
      ],
      "gas": "0"
    },
    "signatures": null,
    "memo": ""
  }
}


         */
        
        // public Transaction SignTransaction(Key pk, object data, string chain_id)
        // {
        //     Payload payload = new Payload(
        //         sessionAccount,
        //         chain_id,
        //         ,
        //         data.value.memo,
        //         );
        // }
        
    }
}