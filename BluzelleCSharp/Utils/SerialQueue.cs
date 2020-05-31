using System;
using System.Threading.Tasks;

namespace BluzelleCSharp.Utils
{
    /**
     * <summary>Implements FIFO async task queue</summary>
     */
    public class SerialQueue
    {
        private readonly WeakReference<Task> _lastTask = new WeakReference<Task>(null);
        private readonly object _locker = new object();

        public Task<T> Enqueue<T>(Func<Task<T>> asyncFunction)
        {
            lock (_locker)
            {
                Task<T> resultTask;

                if (_lastTask.TryGetTarget(out var lastTask))
                    resultTask = lastTask
                        .ContinueWith(_ => asyncFunction(), TaskContinuationOptions.ExecuteSynchronously).Unwrap();
                else
                    resultTask = Task.Run(asyncFunction);

                _lastTask.SetTarget(resultTask);

                return resultTask;
            }
        }
    }
}