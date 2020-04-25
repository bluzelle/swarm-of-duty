using System.Collections.Generic;

namespace BluzelleCSharp.Models
{
    public struct Account
    {
        public struct Coin
        {
            public string Amount;
            public string Denom;
        }

        public struct AccountData
        {
            public string Address;
            public string PublicKey;
            public int AccountNumber;
            public int Sequence;
            public List<Coin> Coins;
        }
        
        public string Type;
        public AccountData Value;
    }
}