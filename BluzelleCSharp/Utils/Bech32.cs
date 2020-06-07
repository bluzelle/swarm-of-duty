using System.Collections.Generic;
using System.Text;
using NBitcoin.DataEncoders;

namespace BluzelleCSharp.Utils
{
    /**
     * <summary>Inherited from <see cref="Bech32Encoder"/> to get access to <see cref="Bech32Encoder.ConvertBits"/></summary>
     */
    public class Bech32: Bech32Encoder
    {
        /**
         * <param name="hrp">Prefix for Bech32</param>
         */
        public Bech32(string hrp) : base(Encoding.ASCII.GetBytes(hrp)) { }

        /**
         * <summary>Encodes input byte array (8 bits) using Bech32</summary>
         * <param name="data">Input byte array</param>
         */
        public string Encode(IEnumerable<byte> data)
        {
            return EncodeData(ConvertBits(data, 8, 5));
        }
    }
}