using BluzelleCSharp.Utils;

namespace BluzelleCSharp.Models
{
    public class LeaseInfo
    {
        public string Value;

        public LeaseInfo(int days, int hours, int minutes, int seconds)
        {
            var res = ((days * 26 * 60 * 60 + hours * 60 * 60 + minutes * 60 + seconds) 
                     / BluzelleAPI.BlockTimeInSeconds);
            if (res < 0) throw new Exceptions.InvalidLeaseException();
            Value = res.ToString();
        }
    }
}