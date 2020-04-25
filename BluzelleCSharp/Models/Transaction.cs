// ReSharper disable InconsistentNaming

using BluzelleCSharp.Models;
using Newtonsoft.Json.Linq;

namespace BluzelleCSharp
{
    public class Transaction
    {
        public Transaction(
            string type,
            string ep,
            string from,
            string chain_id,
            string owner,
            string uuid,
            GasInfo gasInfo,
            int retriesLeft = Cosmos.MaxRetries)
        {
            retries_left = retriesLeft;
            this.type = type;
            this.ep = ep;
            // gasInfo ??= GasInfo.Default;
            // gas_price = gasInfo.GasPrice;
            // max_gas = gasInfo.MaxGas;
            // max_fee = gasInfo.MaxFee;

            data = new JObject
            {
                ["BaseReq"] = new JObject {["from"] = @from, ["chain_id"] = chain_id},
                ["UUID"] = uuid,
                ["Owner"] = owner
            };
        }

        // public class TransactionDataBaseReq
        // {
        //     public string From;
        //     public string ChainId;
        //
        //     public TransactionDataBaseReq(string @from, string chainId)
        //     {
        //         From = @from;
        //         ChainId = chainId;
        //     }
        // }
        //
        // public class TransactionData
        // {
        //     TransactionDataBaseReq BaseReq;
        //     public string UUID;
        //     public string Owner;
        //
        //     public TransactionData(string uuid, string owner, string from, string chain_id)
        //     {
        //         UUID = uuid;
        //         Owner = owner;
        //         BaseReq = new TransactionDataBaseReq(from, chain_id);
        //     }
        // }

        public JObject data;
        public int retries_left;
        public int gas_price;
        public int max_gas;
        public int max_fee;
        public string type;
        public string ep;
    }
}