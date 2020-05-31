using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using BluzelleCSharp;
using BluzelleCSharp.Models;
using Microsoft.Extensions.Configuration;
using NBitcoin;
using NUnit.Framework;
using Utils = BluzelleCSharp.Utils.Utils;

namespace BluzelleTests
{
    public class Tests
    {
        private BluzelleApi _bz;
        private IConfigurationSection _config;
        private GasInfo _gas;
        private Key _privateKey;

        [SetUp]
        public void Setup()
        {
            _config = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .Build()
                .GetSection("Bluzelle");
            _privateKey = Utils.MnemonicToPrivateKey(_config["Mnemonic"]);

            _bz = new BluzelleApi(_config["Namespace"], _config["Mnemonic"], _config["Address"]);
            _gas = new GasInfo {GasPrice = 10};

            CallBlzCli("keys add --recover test --keyring-backend test", _config["Mnemonic"]);
        }

        private string CallBlzCli(string cmd, string write = null)
        {
            var p = new Process
            {
                StartInfo =
                {
                    UseShellExecute = false, RedirectStandardOutput = true, RedirectStandardInput = true,
                    FileName = "blzcli",
                    Arguments = cmd
                }
            };
            p.Start();
            if (write != null)
            {
                p.StandardInput.WriteLine(write);
            }

            var output = p.StandardOutput.ReadToEnd();
            p.WaitForExit();
            return output;
        }

        [Test]
        public async Task TestAccount()
        {
            var res = await _bz.GetAccount();
            Assert.That(res.Address, Is.EqualTo(_config["Address"]));
            Assert.That(res.Coins, Is.Not.Empty);
            Assert.That(res.Coins[0].Denom, Is.EqualTo("ubnt"));
        }

        [Test]
        public async Task TestCreate()
        {
            return;
            var key = Utils.MakeRandomString(10);
            await _bz.Create(key, "testVal",
                new LeaseInfo(0, 1, 0, 0),
                _gas);
            var res = CallBlzCli(
                $"q crud read {_config["Namespace"]} {key} --node http://testnet.public.bluzelle.com:1317");
            Console.WriteLine(res);
        }

        [Test]
        [Retry(3)]
        public async Task TestRead()
        {
            return;
            var key = Utils.MakeRandomString(10);
            await _bz.Create(key, "testVal",
                new LeaseInfo(0, 1, 0, 0),
                _gas);

            Assert.That(await _bz.Read(key), Is.EqualTo("testVal"));
            Assert.ThrowsAsync<KeyNotFoundException>(async () => await _bz.Read(Utils.MakeRandomString(10)));
        }
    }
}