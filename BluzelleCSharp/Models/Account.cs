using System.Collections.Generic;

namespace BluzelleCSharp.Models
{
    public struct Account
    {
        public struct Coin
        {
            public string amount;
            public string denom;
        }

        public struct AccountData
        {
            public string address;
            public string public_key;
            public int account_number;
            public int sequence;
            public List<Coin> coins;
        }
        
        public string type;
        public AccountData value;
    }
}