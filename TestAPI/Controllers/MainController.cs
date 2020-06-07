using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using BluzelleCSharp;
using BluzelleCSharp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json.Linq;
using TestAPI.Interfaces;

namespace TestAPI.Controllers
{
    [ApiController]
    [Route("/")]
    [Produces("application/json")]
    public class MainController : ControllerBase
    {
        private BluzelleApi _bz;
        private GasInfo _gas;

        public MainController(IBlzApi blzApi)
        {
            _bz = blzApi.Api;
            _gas = blzApi.Gas;
        }

        [HttpPost]
        public async Task<IActionResult> PostTest(MethodRunRequest req)
        {
            try
            {
                switch (req.Method)
                {
                    case "create":
                        await _bz.Create(req.Args[0], req.Args[1], new LeaseInfo(int.Parse(req.Args[2])), _gas);
                        break;
                    case "txRead":
                        Console.WriteLine(await _bz.TxRead(req.Args[0], _gas));
                        break;
                    case "update":
                        await _bz.Update(req.Args[0], req.Args[1], new LeaseInfo(int.Parse(req.Args[2])), _gas);
                        break;
                    case "delete":
                        await _bz.Delete(req.Args[0], _gas);
                        break;
                    case "txHas":
                        Console.WriteLine(await _bz.TxHas(req.Args[0], _gas));
                        break;
                    case "txKeys":
                        foreach (var key in await _bz.TxKeys(_gas))
                            Console.WriteLine(key);
                        break;
                    case "read":
                        Console.WriteLine(await _bz.Read(req.Args[0], req.Args.Length > 2));
                        break;
                    case "has":
                        Console.WriteLine(await _bz.HasKey(req.Args[0]));
                        break;
                    case "keys":
                        foreach (var key in await _bz.Keys()) Console.WriteLine(key);
                        break;
                    case "rename":
                        await _bz.Rename(req.Args[0], req.Args[1], _gas);
                        break;
                    case "count":
                        Console.WriteLine(await _bz.Count());
                        break;
                    case "txCount":
                        Console.WriteLine(await _bz.TxCount(_gas));
                        break;
                    case "deleteAll":
                        await _bz.DeleteAll(_gas);
                        break;
                    case "keyValues":
                        foreach (var (key, value) in await _bz.GetKeyValues()) Console.WriteLine($"{key}: {value}");
                        break;
                    case "txKeyValues":
                        foreach (var (key, value) in await _bz.TxGetKeyValues(_gas)) Console.WriteLine($"{key}: {value}");
                        break;
                    case "multiUpdate":
                        var data = new Dictionary<string, string>();
                        for (var i = 1; i < req.Args.Length; i += 2) data.Add(req.Args[i], req.Args[i + 1]);
                        await _bz.UpdateMany(data, _gas);
                        break;
                    case "getLease":
                        Console.WriteLine(await _bz.GetLease(req.Args[0]));
                        break;
                    case "txGetLease":
                        Console.WriteLine(await _bz.TxGetLease(req.Args[0], _gas));
                        break;
                    case "renewLease":
                        await _bz.Renew(req.Args[0], new LeaseInfo(int.Parse(req.Args[1])), _gas);
                        break;
                    case "renewLeaseAll":
                        await _bz.RenewAll(new LeaseInfo(int.Parse(req.Args[0])), _gas);
                        break;
                    case "getNShortestLease":
                        foreach (var (key, value) in await _bz.GetNShortestLease(int.Parse(req.Args[0])))
                            Console.WriteLine($"{key} - {value}");
                        break;
                    case "txGetNShortestLease":
                        foreach (var (key, value) in await _bz.TxGetNShortestLease(int.Parse(req.Args[0]), _gas))
                            Console.WriteLine($"{key} - {value}");
                        break;
                    case "account":
                        var res = _bz.GetAccount().Result;
                        Console.WriteLine($"{res.Address} - {res.Coins[0].Amount} {res.Coins[0].Denom}");
                        break;
                    case "version":
                        Console.WriteLine(_bz.GetVersion().Result);
                        break;
                    default:
                        return StatusCode(400);
                }
            }
            catch (Exception exception)
            {
                return StatusCode(400, exception.Message);
            }

            return Ok("result");
        }
    }
}