using System.Text.Json;

namespace BluzelleCSharp.Models
{
    public class ResponceResult<T>
    {
        public string type { get; set; }
        public T value { get; set; }
    }
    
    public class Responce<T>
    {
        public ResponceResult<T> result { get; set; }
    }
}