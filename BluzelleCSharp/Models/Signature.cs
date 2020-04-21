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
        public string type { get; }
        public string value { get; }

        public SignaturePubKey(Key privateKey, string type = "tendermint/PubKeySecp256k1")
        {
            this.type = type;
            value = Convert.ToBase64String(Encoding.UTF8.GetBytes(privateKey.PubKey.ToHex()));
        }

    }
    
    public class Signature
    {
        public SignaturePubKey pub_key { get; }
        public string signature { get; }
        public string account_number { get; }
        public string sequence { get; }

        public Signature(
            Key pub_key,
            string signature,
            string account_number,
            string sequence)
        {
            this.pub_key = new SignaturePubKey(pub_key);
            this.signature = signature;
            this.account_number = account_number;
            this.sequence = sequence;
        }
    }
}