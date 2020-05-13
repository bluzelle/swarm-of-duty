using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NBitcoin.DataEncoders;

namespace BluzelleCSharp
{
    public class Bech32: Bech32Encoder
    {
        public Bech32(string hrp) : base(Encoding.ASCII.GetBytes(hrp)) { }

        public string Encode(IEnumerable<byte> data)
        {
            return EncodeData(ConvertBits(data, 8, 5));
        }
    }
}