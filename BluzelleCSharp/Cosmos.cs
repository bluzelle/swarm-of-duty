using System;
using System.Collections.Generic;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using BluzelleCSharp.Models;
using BluzelleCSharp.Utils;
using NBitcoin;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using RestSharp;
using RestSharp.Serializers.NewtonsoftJson;
using static BluzelleCSharp.Utils.Utils;

namespace BluzelleCSharp
{
    public class Cosmos
    {
        private const string SvfErrorMessage = "signature verification failed";
        private const string KnfErrorMessage = "Key does not exist";

        protected const string CrudServicePrefix = "crud";
        private const string TxServicePrefix = "txs";
        public const string TokenName = "ubnt";

        private const int RetryInterval = 1000;
        private const int MaxRetries = 10;
        private readonly string ChainId;

        protected readonly string NamespaceId;

        private readonly RestClient restClient;

        private readonly string sessionAddress;
        private readonly Key sessionPk;
        private int sessionAccount;

        private int sessionSequence;

        public Cosmos(
            string namespaceId,
            string mnemonic,
            string address,
            string chainId = "bluzelle",
            string endpoint = "http://testnet.public.bluzelle.com:1317")
        {
            ChainId = chainId;
            NamespaceId = namespaceId;
            sessionPk = MnemonicToPrivateKey(mnemonic);
            sessionAddress = GetAddress(sessionPk.PubKey);

            if (sessionAddress != address) throw new Exceptions.MnemonicInvalidException();

            restClient = new RestClient(endpoint);
            restClient.UseNewtonsoftJson(new JsonSerializerSettings
            {
                ContractResolver = new DefaultContractResolver
                {
                    NamingStrategy = new SnakeCaseNamingStrategy()
                },
                NullValueHandling = NullValueHandling.Ignore
            });

            UpdateAccount();
        }

        public async Task<T> Query<T>(string query)
        {
            return (await restClient.GetAsync<Responce<T>>(
                new RestRequest(UrlEncoder.Default.Encode(query), DataFormat.Json))).Result;
        }

        public async Task<JObject> Query(string query)
        {
            return await restClient.GetAsync<JObject>(
                new RestRequest(UrlEncoder.Default.Encode(query), DataFormat.Json));
        }

        private bool UpdateAccount()
        {
            var accountData = GetAccount(sessionAddress, true).Result;
            try
            {
                sessionAccount = accountData.AccountNumber;
                if (sessionSequence == accountData.Sequence) return false;
                sessionSequence = accountData.Sequence;
                return true;
            }
            catch
            {
                throw new Exceptions.InitializationException();
            }
        }

        public async Task<Account.AccountData> GetAccount(string address, bool update = false)
        {
            return (await Query<Account>($"auth/accounts/{address}")).Value;
        }

        public async Task<JObject> SendTransaction(
            JObject data,
            string type,
            string cmd,
            GasInfo gasInfo = null,
            int retries = MaxRetries)
        {
            data.Merge(new JObject
            {
                ["BaseReq"] = new JObject {["from"] = sessionAddress, ["chain_id"] = ChainId},
                ["UUID"] = NamespaceId,
                ["Owner"] = sessionAddress
            });
            if (gasInfo != null) data.Merge(gasInfo.Obj);

            var methodValid = Enum.TryParse<Method>(type, true, out var httpMethod);
            if (!methodValid) throw new Exception($"HTTP method {type} is unsupported");

            var request = new RestRequest($"{CrudServicePrefix}/{cmd}", httpMethod)
                .AddParameter("application/x-www-form-urlencoded", data, ParameterType.RequestBody);

            var resp = restClient.ExecuteAsync<JObject>(request).Result;
            if (resp.StatusCode != HttpStatusCode.OK) throw new Exceptions.TransactionExecutionException(resp.Content);
            var tx = resp.Data;
            
            gasInfo?.UpdateTransaction(tx);

            tx["value"]!["memo"] = MakeRandomString(32);
            tx["value"]!["signature"] = JObject.FromObject(SignTransaction(tx));
            tx["value"]!["signatures"] = new JArray {tx["value"]["signature"]!};

            var requestBody = new JObject
            {
                ["tx"] = tx["value"],
                ["mode"] = "block",
                ["headers"] = new JObject {["Content-type"] = "application/x-www-form-urlencoded"}
            };
            request = new RestRequest($"{TxServicePrefix}", httpMethod, DataFormat.Json)
                .AddParameter("application/x-www-form-urlencoded", requestBody, ParameterType.RequestBody);

            var res = await restClient.PostAsync<JObject>(request);

            if (res.ContainsKey("code"))
            {
                if (res["raw_log"]!.ToString().Contains(KnfErrorMessage)) throw new KeyNotFoundException();
                if (!res["raw_log"]!.ToString().Contains(SvfErrorMessage))
                    throw new Exceptions.TransactionExecutionException(
                        ExtractErrorFromMessage((string) res["raw_log"]));

                while (retries > 0)
                {
                    retries--;
                    await Task.Delay(RetryInterval);
                    if (UpdateAccount()) return await SendTransaction(data, type, cmd, gasInfo, retries);
                }

                throw new Exceptions.InvalidChainIdException();
            }

            sessionSequence++;
            return ParseTransactionResult((string) res["data"]!);
        }


        private Signature SignTransaction(JObject data)
        {
            var str = JsonConvert.SerializeObject(new JObject
            {
                ["account_number"] = sessionAccount.ToString(),
                ["chain_id"] = ChainId,
                ["fee"] = SortJObject(data["value"]!["fee"]),
                ["memo"] = data["value"]!["memo"],
                ["msgs"] = SortJObject(data["value"]["msg"]),
                ["sequence"] = sessionSequence.ToString()
            });

            str = EscapeCosmosString(str);

            var hash = SHA256.Create().ComputeHash(Encoding.UTF8.GetBytes(str));

            // Create signature and remove first byte when encoding base64, because SignCompact returns header+R+S
            var signature = Convert.ToBase64String(
                sessionPk.SignCompact(new uint256(hash), false),
                1, 64);

            return new Signature(
                sessionPk,
                signature,
                sessionAccount.ToString(),
                sessionSequence.ToString());
        }

        public Task<JObject> SendTransaction(
            string type,
            string cmd,
            GasInfo gasInfo = null)
        {
            return SendTransaction(new JObject(), type, cmd, gasInfo);
        }
    }
}