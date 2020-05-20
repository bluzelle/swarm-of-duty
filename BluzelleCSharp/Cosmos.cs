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
using Threading;
using static BluzelleCSharp.Utils.Utils;

namespace BluzelleCSharp
{
    /**
     * <summary>
     * Class implements main Cosmos network 
     * </summary>
     **/
    public class Cosmos
    {
        private const string SvfErrorMessage = "signature verification failed";
        private const string KnfErrorMessage = "Key does not exist";

        protected const string CrudServicePrefix = "crud";
        private const string TxServicePrefix = "txs";
        public const string TokenName = "ubnt";

        private const int RetryInterval = 1000;
        private const int MaxRetries = 10;
        private readonly string _chainId;

        private readonly RestClient _restClient;

        private readonly string _sessionAddress;
        private readonly Key _sessionPk;

        private readonly SerialQueue _transactionQueue;

        protected readonly string NamespaceId;
        private int _sessionAccount;
        private int _sessionSequence;

        public Cosmos(
            string namespaceId,
            string mnemonic,
            string address,
            string chainId = "bluzelle",
            string endpoint = "http://testnet.public.bluzelle.com:1317")
        {
            _chainId = chainId;
            NamespaceId = namespaceId;
            _sessionPk = MnemonicToPrivateKey(mnemonic);
            _sessionAddress = GetAddress(_sessionPk.PubKey);

            if (_sessionAddress != address) throw new Exceptions.MnemonicInvalidException();

            _restClient = new RestClient(endpoint);
            _restClient.UseNewtonsoftJson(new JsonSerializerSettings
            {
                ContractResolver = new DefaultContractResolver
                {
                    NamingStrategy = new SnakeCaseNamingStrategy()
                },
                NullValueHandling = NullValueHandling.Ignore
            });

            _transactionQueue = new SerialQueue();
            
            UpdateAccount();
        }

        public async Task<T> Query<T>(string query)
        {
            return (await _restClient.GetAsync<Responce<T>>(
                new RestRequest(UrlEncoder.Default.Encode(query), DataFormat.Json))).Result;
        }

        public async Task<JObject> Query(string query)
        {
            return await _restClient.GetAsync<JObject>(
                new RestRequest(UrlEncoder.Default.Encode(query), DataFormat.Json));
        }

        private bool UpdateAccount()
        {
            var accountData = GetAccount(_sessionAddress, true).Result;
            try
            {
                _sessionAccount = accountData.AccountNumber;
                if (_sessionSequence == accountData.Sequence) return false;
                _sessionSequence = accountData.Sequence;
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

        public Task<JObject> SendTransaction(
            JObject data,
            string type,
            string cmd,
            GasInfo gasInfo = null)
        {
            return _transactionQueue.Enqueue(() => ExecuteTransaction(data, type, cmd, gasInfo));
        }

        public Task<JObject> SendTransaction(
            string type,
            string cmd,
            GasInfo gasInfo = null)
        {
            return SendTransaction(new JObject(), type, cmd, gasInfo);
        }

        private async Task<JObject> ExecuteTransaction(
            JObject data,
            string type,
            string cmd,
            GasInfo gasInfo = null,
            int retries = MaxRetries)
        {
            data.Merge(new JObject
            {
                ["BaseReq"] = new JObject {["from"] = _sessionAddress, ["chain_id"] = _chainId},
                ["UUID"] = NamespaceId,
                ["Owner"] = _sessionAddress
            });
            if (gasInfo != null) data.Merge(gasInfo.Obj);

            var methodValid = Enum.TryParse<Method>(type, true, out var httpMethod);
            if (!methodValid) throw new Exception($"HTTP method {type} is unsupported");

            var request = new RestRequest($"{CrudServicePrefix}/{cmd}", httpMethod)
                .AddParameter("application/x-www-form-urlencoded", data, ParameterType.RequestBody);

            var resp = _restClient.ExecuteAsync<JObject>(request).Result;
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

            var res = await _restClient.PostAsync<JObject>(request);

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
                    if (UpdateAccount()) return await ExecuteTransaction(data, type, cmd, gasInfo, retries);
                }

                throw new Exceptions.InvalidChainIdException();
            }

            _sessionSequence++;
            return ParseTransactionResult((string) res["data"]!);
        }

        private Signature SignTransaction(JObject data)
        {
            var str = JsonConvert.SerializeObject(new JObject
            {
                ["account_number"] = _sessionAccount.ToString(),
                ["chain_id"] = _chainId,
                ["fee"] = SortJObject(data["value"]!["fee"]),
                ["memo"] = data["value"]!["memo"],
                ["msgs"] = SortJObject(data["value"]["msg"]),
                ["sequence"] = _sessionSequence.ToString()
            });

            str = EscapeCosmosString(str);

            var hash = SHA256.Create().ComputeHash(Encoding.UTF8.GetBytes(str));

            // Create signature and remove first byte when encoding base64, because SignCompact returns header+R+S
            var signature = Convert.ToBase64String(
                _sessionPk.SignCompact(new uint256(hash), false),
                1, 64);

            return new Signature(
                _sessionPk,
                signature,
                _sessionAccount.ToString(),
                _sessionSequence.ToString());
        }
    }
}