// ReSharper disable InconsistentNaming
namespace BluzelleCSharp
{
    public class Transaction
    {
        public Transaction(
            string type,
            string ep,
            object data,
            int gasPrice,
            int maxGas = 0,
            int maxFee = 0,
            int retriesLeft = Cosmos.MaxRetries)
        {
            this.type = type;
            this.ep = ep;
            this.data = data;
            gas_price = gasPrice;
            max_gas = maxGas;
            max_fee = maxFee;
            retries_left = retriesLeft;
        }

        public string type { get; set; }
        public string ep { get; set; }
        public object data { get; set; }
        public int gas_price { get; set; }
        public int max_gas { get; set; }
        public int max_fee { get; set; }
        public int retries_left { get; set; }
    }
}