using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using BluzelleCSharp;
using BluzelleCSharp.Models;
using Microsoft.Extensions.Configuration;

namespace ExampleApp
{
    internal static class Program
    {
        private static void Main(string[] args)
        {
            Process(args).Wait();
        }

        private static void PrintHelp()
        {
            Console.Write("\nCommandline Arguments: command [ argument...]\n" +
                          " Executes a command on a Bluzelle node\n\n" +
                          "Commands and arguments:\n" +
                          "\n Transactional commands\n" +
                          "  create key value [lease] - creates a new key/value, optionally with a lease (in seconds)\n" +
                          "  txRead key               - returns the value of an existing key\n" +
                          "  update key value [lease] - updates the value of an existing key, optionally with a lease (in seconds)\n" +
                          "  delete key               - deletes an existing key\n" +
                          "  rename key newkey        - updates the name of an existing key\n" +
                          "  txHas key                - determines if a key exists\n" +
                          "  txKeys                   - returns a list of all keys\n" +
                          "  txCount                  - returns the number of keys\n" +
                          "  txKeyValues              - returns a list of all keys and values\n" +
                          "  deleteAll                - deletes all keys\n" +
                          "  txGetLease key           - returns the lease time (in seconds) remaining for a key\n" +
                          "  renewLease key           - updates the lease time for a key, optionally with a lease (in seconds)\n" +
                          "  renewLeaseAll [lease]    - updates the lease time for all keys, optionally with a lease (in seconds)\n" +
                          "  txGetNShortestLease n    - returns the n keys/leases with the shortest least time\n" +
                          "\n  multiUpdate key value [key value]... - updates the value of multiple existing keys\n" +
                          "\n Query commands\n" +
                          "  read key [prove]    - returns the value of an existing key, requiring proof if 'prove' is specified\n" +
                          "  has key             - determines if a key exists\n" +
                          "  keys                - returns a list of all keys\n" +
                          "  keyValues           - returns a list of all keys and values\n" +
                          "  count               - returns the number of keys\n" +
                          "  getLease key        - returns the lease time (in seconds) remaining for a key\n" +
                          "  getNShortestLease n - returns the n keys/leases with the shortest least time\n" +
                          "\n Miscellaneous commands\n" +
                          "  account             - returns information about the currently active account\n" +
                          "  version             - returns the version of the Bluzelle service\n" +
                          "  help                - prints this message");
            Environment.Exit(0);
        }

        private static async Task Process(string[] args)
        {
            try
            {
                var config = new ConfigurationBuilder()
                    .AddJsonFile("appsettings.json")
                    .Build()
                    .GetSection("Bluzelle");

                var bz = new BluzelleApi(config["Namespace"], config["Mnemonic"], config["Address"]);
                var gas = new GasInfo {GasPrice = 10};

                if (args.Length == 0) PrintHelp();
                switch (args[0])
                {
                    case "create":
                        await bz.Create(args[1], args[2], new LeaseInfo(int.Parse(args[3])), gas);
                        break;
                    case "txRead":
                        Console.WriteLine(await bz.TxRead(args[1], gas));
                        break;
                    case "update":
                        await bz.Update(args[1], args[2], new LeaseInfo(int.Parse(args[3])), gas);
                        break;
                    case "delete":
                        await bz.Delete(args[1], gas);
                        break;
                    case "txHas":
                        Console.WriteLine(await bz.TxHas(args[1], gas));
                        break;
                    case "txKeys":
                        foreach (var key in await bz.TxKeys(gas))
                            Console.WriteLine(key);
                        break;
                    case "read":
                        Console.WriteLine(await bz.Read(args[1], args.Length > 2));
                        break;
                    case "has":
                        Console.WriteLine(await bz.HasKey(args[1]));
                        break;
                    case "keys":
                        foreach (var key in await bz.Keys()) Console.WriteLine(key);
                        break;
                    case "rename":
                        await bz.Rename(args[1], args[2], gas);
                        break;
                    case "count":
                        Console.WriteLine(await bz.Count());
                        break;
                    case "txCount":
                        Console.WriteLine(await bz.TxCount(gas));
                        break;
                    case "deleteAll":
                        await bz.DeleteAll(gas);
                        break;
                    case "keyValues":
                        foreach (var (key, value) in await bz.GetKeyValues()) Console.WriteLine($"{key}: {value}");
                        break;
                    case "txKeyValues":
                        foreach (var (key, value) in await bz.TxGetKeyValues(gas)) Console.WriteLine($"{key}: {value}");
                        break;
                    case "multiUpdate":
                        var data = new Dictionary<string, string>();
                        for (var i = 1; i < args.Length; i += 2) data.Add(args[i], args[i + 1]);
                        await bz.UpdateMany(data, gas);
                        break;
                    case "getLease":
                        Console.WriteLine(await bz.GetLease(args[1]));
                        break;
                    case "txGetLease":
                        Console.WriteLine(await bz.TxGetLease(args[1], gas));
                        break;
                    case "renewLease":
                        await bz.Renew(args[1], new LeaseInfo(int.Parse(args[2])), gas);
                        break;
                    case "renewLeaseAll":
                        await bz.RenewAll(new LeaseInfo(int.Parse(args[1])), gas);
                        break;
                    case "getNShortestLease":
                        foreach (var (key, value) in await bz.GetNShortestLease(int.Parse(args[1])))
                            Console.WriteLine($"{key} - {value}");
                        break;
                    case "txGetNShortestLease":
                        foreach (var (key, value) in await bz.TxGetNShortestLease(int.Parse(args[1]), gas))
                            Console.WriteLine($"{key} - {value}");
                        break;
                    case "account":
                        var res = bz.GetAccount().Result;
                        Console.WriteLine($"{res.Address} - {res.Coins[0].Amount} {res.Coins[0].Denom}");
                        break;
                    case "version":
                        Console.WriteLine(bz.GetVersion().Result);
                        break;
                    default:
                        PrintHelp();
                        return;
                }
            }
            catch (Exception exception)
            {
                Console.WriteLine(exception.Message);
                PrintHelp();
            }
        }
    }
}