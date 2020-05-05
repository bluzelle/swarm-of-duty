using System;
using System.Linq;
using Newtonsoft.Json.Linq;

namespace BluzelleCSharp
{
    public class Utils
    {
        public static string SanitizeString(string str)
        {
            var result = "";
            foreach (var ch in str)
                switch (ch)
                {
                    case '&':
                    case '<':
                    case '>':
                        result += "\\u00" + ((int) ch).ToString("X");
                        break;
                    default:
                        result += ch;
                        break;
                }

            return result;
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
                    foreach (var (key, value) in (JObject) data)
                    {
                        data[key] = SortJObject(value);
                    }
                    return data;
                }
                case JTokenType.Array:
                    return new JArray {
                        data
                        .OrderBy(i => i.Type == JTokenType.Array ? i.Count() : i)
                        .Select(SortJObject)
                    };
                default:
                    return data;
            }
        }
    }
}