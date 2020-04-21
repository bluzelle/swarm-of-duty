using System;
using System.IO.Compression;
using System.Linq;
using BluzelleCSharp.Models;
using NBitcoin;
using NBitcoin.Crypto;
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

        private RestClient restClient;

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

            Query("node_info");
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

        async public void Query(string query)
        {
            var response = await restClient.GetAsync<Responce<object>>(new RestRequest(query, DataFormat.Json));
            Console.WriteLine(response.result);
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