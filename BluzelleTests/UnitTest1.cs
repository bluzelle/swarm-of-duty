using BluzelleCSharp;
using BluzelleCSharp.Models;
using Microsoft.Extensions.Configuration;
using NUnit.Framework;

namespace BluzelleTests
{
    public class Tests
    {
        private BluzelleApi _bz;
        private GasInfo _gas;

        [SetUp]
        public void Setup()
        {
            var config = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .Build()
                .GetSection("Bluzelle");

            _bz = new BluzelleApi(config["Namespace"], config["Mnemonic"], config["Address"]);
            _gas = new GasInfo {GasPrice = 10};
        }

        [Test]
        public void Test1()
        {
            Assert.Pass();
        }
    }
}