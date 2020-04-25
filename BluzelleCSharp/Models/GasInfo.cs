using System;
using System.ComponentModel;
using Newtonsoft.Json.Linq;

namespace BluzelleCSharp.Models
{
    public class GasInfo
    {
        [DefaultValue(null)]
        public int? GasPrice;
        [DefaultValue(null)]
        public int? MaxGas;
        [DefaultValue(null)]
        public int? MaxFee;

        public GasInfo(int? gasPrice, int? maxGas, int? maxFee)
        {
            GasPrice = gasPrice;
            MaxGas = maxGas;
            MaxFee = maxFee;
        }

        public JObject Obj =>
            new JObject
            {
                ["max_gas"] = MaxGas != null ? MaxGas.ToString() : null,
                ["max_fee"] = MaxFee != null ? MaxFee.ToString() : null,
                ["gas_price"] = GasPrice != null ? GasPrice.ToString() : null,
            };

        public void UpdateTransaction(JObject res)
        {
            var gas = res["value"]!["fee"]!["gas"]!.ToObject<int>();
            if(MaxGas != null && gas > MaxGas)
                res["value"]!["fee"]!["gas"] = MaxGas.ToString();
            if(MaxFee != null || GasPrice != null)
                res["value"]!["fee"]!["amount"] = new JArray{new JObject
                {
                    ["denom"] = Cosmos.TokenName,
                    ["amount"] = (MaxFee ?? GasPrice *  gas).ToString()
                }};
        }
    }
}