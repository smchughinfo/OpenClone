using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using OpenClone.Core.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Services.Logging
{
    public class LoggerProvider : ILoggerProvider
    {
        private readonly Func<string, LogLevel, bool> _filter;
        private readonly IServiceProvider _serviceProvider;

        public LoggerProvider(Func<string, LogLevel, bool> filter, IServiceProvider serviceProvider)
        {
            _filter = filter;
            _serviceProvider = serviceProvider;
        }

        public ILogger CreateLogger(string categoryName)
        {
            var logWriter = _serviceProvider.GetRequiredService<LogWriter>();
            return new Logger(categoryName, _filter, logWriter);
        }

        public void Dispose() { }
    }

}
