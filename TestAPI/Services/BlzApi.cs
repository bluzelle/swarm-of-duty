using BluzelleCSharp;
using BluzelleCSharp.Models;
using Microsoft.Extensions.Configuration;
using TestAPI.Interfaces;

namespace TestAPI.Services
{
    public class BlzApi : IBlzApi
    {
        public BluzelleApi Api { get; }
        public GasInfo Gas { get; }

        public BlzApi(IConfiguration configuration)
        {
            var config = configuration.GetSection("Bluzelle");
            Api = new BluzelleApi(config["Namespace"], config["Mnemonic"], config["Address"]);
            Gas = new GasInfo {GasPrice = 10};
        }
    }
}