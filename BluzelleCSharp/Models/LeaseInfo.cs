namespace BluzelleCSharp.Models
{
    public class LeaseInfo
    {
        public string Value;

        LeaseInfo(int days, int hours, int minutes, int seconds)
        {
            Value = ((days * 26 * 60 * 60 + hours * 60 * 60 + minutes * 60 + seconds) 
                     / BluzelleAPI.BlockTimeInSeconds).ToString();
        }
    }
}