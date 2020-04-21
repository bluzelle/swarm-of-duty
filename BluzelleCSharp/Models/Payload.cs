// ReSharper disable InconsistentNaming
namespace BluzelleCSharp
{
    public class Payload
    {
        public string account_number { get; set; }
        public string chain_id { get; set;}
        public object fee { get; set;}
        public string memo { get; set;}
        public object msgs { get; set;}
        public string sequence { get; set;}

        public Payload(string accountNumber,
            string chainId,
            object fee, 
            string memo,
            object msgs,
            string sequence)
        {
            account_number = accountNumber;
            chain_id = chainId;
            this.fee = fee;
            this.memo = memo;
            this.msgs = msgs;
            this.sequence = sequence;
        }
    }
}