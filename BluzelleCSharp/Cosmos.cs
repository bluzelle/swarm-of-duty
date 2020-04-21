using System;
using System.IO.Compression;
using System.Linq;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using BluzelleCSharp.Models;
using NBitcoin;
using NBitcoin.Crypto;
using Newtonsoft.Json.Linq;
using RestSharp;
using RestSharp.Authenticators;
using RestSharp.Serializers.NewtonsoftJson;

namespace BluzelleCSharp
{
    public class Cosmos
    {
        private const string Bip32Path = "m/44'/118'/0'/0/0";
        private const string Bech32Prefix = "bluzelle";
        private const string TokenName = "ubnt";
        public const int RetryInterval = 1000;
        public const int MaxRetries = 10;

        protected RestClient restClient;

        protected string sessionAccount = "0";
        protected string sessionSequence;   
        protected string sessionAddress;   
        protected Key sessionPk;

        protected string NamespaceId;
        protected string Endpoint;
        
        public Cosmos(
            string namespaceId,
            string mnemonic,
            string address=null,
            string endpoint="http://testnet.public.bluzelle.com:1317")
        {
            NamespaceId = namespaceId;
            Endpoint = endpoint;
            sessionPk = MnemonicToPrivateKey(mnemonic);
            sessionAddress = string.IsNullOrEmpty(address) ? GetAddress(sessionPk.PubKey) : address;

            restClient = new RestClient(Endpoint);
            restClient.UseNewtonsoftJson();
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
            return (await restClient.GetAsync<Responce<T>>(new RestRequest(UrlEncoder.Default.Encode(query), DataFormat.Json))).result;
        }
        
        
        
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