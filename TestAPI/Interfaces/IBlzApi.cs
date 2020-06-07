using BluzelleCSharp;
using BluzelleCSharp.Models;

namespace TestAPI.Interfaces
{
    public interface IBlzApi
    {
        BluzelleApi Api { get; }
        GasInfo Gas { get; }
    }
}