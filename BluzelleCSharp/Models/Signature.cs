// ReSharper disable InconsistentNaming

using System;
using System.Buffers.Text;
using System.Collections.ObjectModel;
using System.Text;
using System.Text.Unicode;
using NBitcoin;

namespace BluzelleCSharp
{
    public class SignaturePubKey
    {
        public string type;
        public string value;

        public SignaturePubKey(Key privateKey, string type = "tendermint/PubKeySecp256k1")
        {
            this.type = type;
            value = Convert.ToBase64String(Encoding.UTF8.GetBytes(privateKey.PubKey.ToHex()));
        }
    }
    
    public class Signature
    {
        public SignaturePubKey pub_key;
        public string signature;
        public string account_number;
        public string sequence;

        public Signature(
            Key pk,
            string signature,
            string account_number,
            string sequence)
        {
            pub_key = new SignaturePubKey(pk);
            this.signature = signature;
            this.account_number = account_number;
            this.sequence = sequence;
        }
    }
}