namespace BluzelleCSharp
{
    public class BluzelleAPI : Cosmos
    {
        public BluzelleAPI(string namespaceId, string mnemonic, string address = null, string endpoint = "http://testnet.public.bluzelle.com:1317") : base(namespaceId, mnemonic, address, endpoint) { }
        
        // async public bool hasKey()
    }
}