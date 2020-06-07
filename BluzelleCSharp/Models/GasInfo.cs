using System.ComponentModel;
using Newtonsoft.Json.Linq;

namespace BluzelleCSharp.Models
{
    public class GasInfo
    {
        [DefaultValue(null)] public int? GasPrice;

        [DefaultValue(null)] public int? MaxFee;

        [DefaultValue(null)] public int? MaxGas;

        public GasInfo(int? gasPrice = null, int? maxGas = null, int? maxFee = null)
        {
            GasPrice = gasPrice;
            MaxGas = maxGas;
            MaxFee = maxFee;
        }

        /**
         * <summary>Generate <see cref="JObject"/> based on current gas configuration for transaction data</summary>
         */
        public JObject Obj =>
            new JObject
            {
                ["max_gas"] = MaxGas != null ? MaxGas.ToString() : null,
                ["max_fee"] = MaxFee != null ? MaxFee.ToString() : null,
                ["gas_price"] = GasPrice != null ? GasPrice.ToString() : null
            };

        
        /**
         * <summary>Updates transaction data by inserting existing gas configuration into <paramref name="res"/></summary>
         * <param name="res">Transaction base retrieved from Bluzelle api</param>
         */
        public void UpdateTransaction(JObject res)
        {
            var gas = res["value"]!["fee"]!["gas"]!.ToObject<int>();
            if (MaxGas != null && gas > MaxGas)
                res["value"]!["fee"]!["gas"] = MaxGas.ToString();
            if (MaxFee != null || GasPrice != null)
                res["value"]!["fee"]!["amount"] = new JArray
                {
                    new JObject
                    {
                        ["denom"] = Cosmos.TokenName,
                        ["amount"] = (MaxFee ?? GasPrice * gas).ToString()
                    }
                };
        }
    }
}