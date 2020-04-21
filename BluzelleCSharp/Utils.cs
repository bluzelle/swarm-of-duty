using System;
using System.Collections.Generic;
using System.Linq;

namespace BluzelleCSharp
{
    public class Utils
    {
        public static string SanitizeString(string str)
        {
            var result = "";
            foreach (var ch in str)
            {
                switch (ch)
                {
                    case '&':
                    case '<':
                    case '>':
                        result += "\\u00" + ((int)ch).ToString("X");
                        break;
                    default:
                        result += ch;
                        break;
                }
            }
            return result;
        }
        
        public static string MakeRandomString(int length)
        {
            var result = "";
            const string characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            for (var i = 0; i < length; i++)
                result += characters.Append(characters[new Random().Next(0, characters.Length)]);
            return result;
        }
    }
}