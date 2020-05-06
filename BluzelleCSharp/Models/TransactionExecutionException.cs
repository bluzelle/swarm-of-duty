using System;

namespace BluzelleCSharp.Models
{
    public class TransactionExecutionException : Exception
    {
        public TransactionExecutionException(string err) : base(err)
        {
        }
    }
}