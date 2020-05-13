using System;
using System.Globalization;
using System.Linq;
using NBitcoin;
using NBitcoin.Crypto;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace BluzelleCSharp.Utils
{
    public static class Utils
    {
        private const string Bip32Path = "m/44'/118'/0'/0/0";
        private const string Bech32Prefix = "bluzelle";

        public static JObject ParseTransactionResult(string hex)
        {
            var json = "";
            for (var i = 0; i < hex.Length; i += 2)
                json += (char) int.Parse(hex.Substring(i, 2), NumberStyles.HexNumber);
            return JsonConvert.DeserializeObject<JObject>(json);
        }

        // Like sanitize_string in blzjs - escape utf8 '&', '>' and '<'
        public static string EscapeCosmosString(string str)
        {
            return str.Aggregate("", (acc, x) =>
                acc + (new[] {'&', '>', '<'}.Contains(x) ? $"\\u00{(int) x:X}" : $"{x}"));
        }

        public static string MakeRandomString(int length)
        {
            var result = "";
            const string characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            for (var i = 0; i < length; i++)
                result = result.Insert(0, characters[new Random().Next(0, characters.Length)].ToString());
            return result;
        }

        public static JToken SortJObject(JToken data)
        {
            switch (data.Type)
            {
                case JTokenType.Object:
                {
                    data = new JObject((data as JObject)!.Properties().OrderBy(i => i.Name));
                    foreach (var (key, value) in (JObject) data) data[key] = SortJObject(value);
                    return data;
                }
                case JTokenType.Array:
                    return new JArray
                    {
                        data
                            .OrderBy(i => i.Type == JTokenType.Array ? i.Count() : i)
                            .Select(SortJObject)
                    };
                default:
                    return data;
            }
        }

        public static string ExtractErrorFromMessage(string msg)
        {
            // Credit to BlzJS library. The following code is just a transcription from JS to C#

            // This is very fragile and will break if Cosmos changes their error format again
            // currently it looks like "unauthorized: Key already exists: failed to execute message; message index: 0"
            // and we just want the "Key already exists" bit. However with some messages, e.g.
            // insufficient fee: insufficient fees; got: 10ubnt required: 2000000ubnt
            // we want most of the message.
            // To deal with this, we will in general extract the message between the first two colons in most cases
            // but will have exceptions for certain cases

            var offset1 = msg.IndexOf(": ", StringComparison.Ordinal);

            // If we can't segment the message, just return the whole thing
            if (offset1 == -1) return msg;

            // Exception cases
            var prefix = msg.Substring(0, offset1);
            switch (prefix)
            {
                case "insufficient fee":
                    return msg.Substring(offset1 + 2);
            }

            var offset2 = msg.IndexOf(':', offset1 + 1);
            return offset2 - offset1 - 2 <= 0 ? msg : msg.Substring(offset1 + 2, offset2 - offset1 - 2);
        }
        
        public static Key MnemonicToPrivateKey(string mnemonic)
        {
            return new Mnemonic(mnemonic, Wordlist.English).DeriveExtKey().Derive(new KeyPath(Bip32Path)).PrivateKey;
        }

        public static string GetAddress(PubKey key)
        {
            var z = Hashes.SHA256(key.ToBytes());
            return new Bech32(Bech32Prefix).Encode(Hashes.RIPEMD160(z, z.Length));
        }
    }
}