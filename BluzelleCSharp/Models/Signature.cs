// ReSharper disable InconsistentNaming

using System;
using NBitcoin;

namespace BluzelleCSharp.Models
{
    public class SignaturePubKey
    {
        public string type;
        public string value;

        public SignaturePubKey(Key privateKey, string type = "tendermint/PubKeySecp256k1")
        {
            this.type = type;
            value = Convert.ToBase64String(privateKey.PubKey.ToBytes());
        }
    }

    public class Signature
    {
        public string account_number;
        public SignaturePubKey pub_key;
        public string sequence;
        public string signature;

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