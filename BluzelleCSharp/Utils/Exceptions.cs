using System;

namespace BluzelleCSharp.Utils
{
    public class Exceptions
    {
        public class MnemonicInvalidException : Exception
        {
        }

        public class InvalidChainIdException : Exception
        {
        }

        public class InitializationException : Exception
        {
        }

        public class InvalidLeaseException : Exception
        {
        }
        
        public class TransactionExecutionException : Exception
        {
            public TransactionExecutionException(string err) : base(err)
            {
            }
        }
    }
}