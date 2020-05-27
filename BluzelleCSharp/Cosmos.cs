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
     *     Class implements main Cosmos network API
     * </summary>
     */
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

        /**
         * <summary>Initializes Cosmos network API</summary>
         * <param name="namespaceId">Bluzelle Database Namespace ID</param>
         * <param name="mnemonic">Mnemonic for account in BIP39</param>
         * <param name="address">Account address in Cosmos format. It'll be verified over given mnemonic</param>
         * <param name="chainId">Database chain ID. For Bluzelle network it equals to "bluzelle"</param>
         * <param name="endpoint">REST API endpoint including protocol and port</param>
         */
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

        /**
         * <summary>Executes non-transaction REST API GET query</summary>
         * <typeparam name="T">Query result format. <see cref="RestSharp.RestClient" /></typeparam>
         * <param name="query">Querystring for HTTP. Will be concatenated with endpoint in <see cref="Cosmos" /> constructor</param>
         * <returns>Query result casted to <typeparamref name="T" /></returns>
         */
        public async Task<T> Query<T>(string query)
        {
            return (await _restClient.GetAsync<Responce<T>>(
                new RestRequest(UrlEncoder.Default.Encode(query), DataFormat.Json))).Result;
        }

        /**
         * <summary>Executes non-transaction REST API GET query without result casting</summary>
         * <param name="query">Querystring for HTTP. Will be concatenated with endpoint in <see cref="Cosmos" /> constructor</param>
         * <returns>Query result in plain <see cref="JObject" /></returns>
         */
        public async Task<JObject> Query(string query)
        {
            return await Query<JObject>(query);
        }

        /**
         * <summary>
         *     Executes <see cref="GetAccount" /> query with auto update of <see cref="_sessionAccount" /> and
         *     <see cref="_sessionSequence" />
         * </summary>
         * <returns>Boolean if account sequence data has updated</returns>
         */
        private bool UpdateAccount()
        {
            var accountData = GetAccount(_sessionAddress).Result;
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

        /**
         * <summary>Executes auth/accounts query</summary>
         * <returns>Account data in <see cref="Account.AccountData" /></returns>
         */
        public async Task<Account.AccountData> GetAccount(string address)
        {
            return (await Query<Account>($"auth/accounts/{address}")).Value;
        }

        /**
         * <summary>
         *     Schedules new transaction request
         *     <see cref="SendTransaction(Newtonsoft.Json.Linq.JObject,string,string,BluzelleCSharp.Models.GasInfo)" /> into FIFO
         *     task queue.
         *     Method will wait until all request before it are done and returns this transaction result via <see cref="Task" />
         * </summary>
         * <param name="data">Transaction data</param>
         * <param name="type">HTTP-style transaction request type</param>
         * <param name="cmd">Transaction command</param>
         * <param name="gasInfo">Gas used to execute transaction</param>
         * <exception cref="Exceptions.InvalidChainIdException"></exception>
         * <exception cref="Exceptions.TransactionExecutionException"></exception>
         * <exception cref="KeyNotFoundException"></exception>
         * <returns>JObject contains decoded transaction result</returns>
         */
        public Task<JObject> SendTransaction(
            JObject data,
            string type,
            string cmd,
            GasInfo gasInfo = null)
        {
            return _transactionQueue.Enqueue(() => ExecuteTransaction(data, type, cmd, gasInfo));
        }

        /**
         * <summary>
         *     Schedules new transaction without parameters.
         *     Uses <see cref="SendTransaction(Newtonsoft.Json.Linq.JObject,string,string,BluzelleCSharp.Models.GasInfo)" />
         * </summary>
         */
        public Task<JObject> SendTransaction(
            string type,
            string cmd,
            GasInfo gasInfo = null)
        {
            return SendTransaction(new JObject(), type, cmd, gasInfo);
        }

        /**
         * <summary>
         *     Executes transaction command <paramref name="cmd" /> with params <paramref name="data" /> of type
         *     <paramref name="type" />.
         *     Function contains auto-retry algorithm with auto sequence error fix. Maximum retries set via
         *     <paramref name="retries" />
         * </summary>
         * <param name="data">Transaction data</param>
         * <param name="type">HTTP-style transaction request type</param>
         * <param name="cmd">Transaction command</param>
         * <param name="gasInfo">Gas used to execute transaction</param>
         * <param name="retries">
         *     Maximum retries count. Retries runs with delay of <see cref="RetryInterval" />ms plus transaction
         *     execution time
         * </param>
         * <returns>JObject contains decoded transaction result</returns>
         * <exception cref="Exceptions.InvalidChainIdException"></exception>
         * <exception cref="Exceptions.TransactionExecutionException"></exception>
         * <exception cref="KeyNotFoundException"></exception>
         */
        private async Task<JObject> ExecuteTransaction(
            JObject data,
            string type,
            string cmd,
            GasInfo gasInfo = null,
            int retries = MaxRetries)
        {
            // Update user request with transaction-specific data and gas information
            data.Merge(new JObject
            {
                ["BaseReq"] = new JObject {["from"] = _sessionAddress, ["chain_id"] = _chainId},
                ["UUID"] = NamespaceId,
                ["Owner"] = _sessionAddress
            });
            if (gasInfo != null) data.Merge(gasInfo.Obj);

            // Decoding transaction type from string
            var methodValid = Enum.TryParse<Method>(type, true, out var httpMethod);
            if (!methodValid) throw new Exception($"HTTP method {type} is unsupported");

            // Run request for retrieving transaction base part (template)
            var request = new RestRequest($"{CrudServicePrefix}/{cmd}", httpMethod)
                .AddParameter("application/x-www-form-urlencoded", data, ParameterType.RequestBody);

            var resp = _restClient.ExecuteAsync<JObject>(request).Result;
            if (resp.StatusCode != HttpStatusCode.OK) throw new Exceptions.TransactionExecutionException(resp.Content);
            var tx = resp.Data;

            gasInfo?.UpdateTransaction(tx);

            // Calculate tx signature and insert it into transaction template
            tx["value"]!["memo"] = MakeRandomString(32);
            tx["value"]!["signature"] = JObject.FromObject(SignTransaction(
                (string) tx["value"]["memo"],
                tx["value"]["fee"],
                tx["value"]["msg"]));
            tx["value"]!["signatures"] = new JArray {tx["value"]["signature"]!};

            var requestBody = new JObject
            {
                ["tx"] = tx["value"],
                ["mode"] = "block",
                ["headers"] = new JObject {["Content-type"] = "application/x-www-form-urlencoded"}
            };
            // Execute transaction
            request = new RestRequest($"{TxServicePrefix}", httpMethod, DataFormat.Json)
                .AddParameter("application/x-www-form-urlencoded", requestBody, ParameterType.RequestBody);

            var res = await _restClient.PostAsync<JObject>(request);

            // If transaction result contains "code" field - it is failed - therefore try to decode 
            if (res.ContainsKey("code"))
            {
                if (res["raw_log"]!.ToString().Contains(KnfErrorMessage)) throw new KeyNotFoundException();

                // If failed due to invalid sequence ID or due to invalid signature,
                // wait, retrieve user data again and then re-execute transaction
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

        /**
         * <summary>Signs transaction for Cosmos network</summary>
         * <param name="memo">Transaction memo string</param>
         * <param name="fee">Transaction fees object (value.fee)</param>
         * <param name="msg">Transaction message object (value.msg)</param>
         * <returns>Transaction signature in <see cref="Signature" /></returns>
         */
        private Signature SignTransaction(string memo, JToken fee, JToken msg)
        {
            // Create transaction object for signing ensuring right fields order.
            var str = JsonConvert.SerializeObject(new JObject
            {
                ["account_number"] = _sessionAccount.ToString(),
                ["chain_id"] = _chainId,
                ["fee"] = SortJObject(fee),
                ["memo"] = memo,
                ["msgs"] = SortJObject(msg),
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