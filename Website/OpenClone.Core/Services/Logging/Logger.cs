using Microsoft.Extensions.Logging;
using OpenClone.Core.Data;
using OpenClone.Core.Extensions;
using OpenClone.Core.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Services.Logging
{
    public class Logger : ILogger
    {
        private readonly string _categoryName;
        private readonly Func<string, LogLevel, bool> _filter;
        private readonly LogWriter _logWriter;

        public Logger(string categoryName, Func<string, LogLevel, bool> filter, LogWriter logWriter)
        {
            _categoryName = categoryName;
            _filter = filter;
            _logWriter = logWriter;
        }

        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            if (!IsEnabled(logLevel))
            {
                return;
            }

            var message = formatter(state, exception);
            var logEntry = new LogEntry
            {
                ApplicationName = _categoryName,
                OpenCloneLog = _categoryName == GlobalVariables.OpenCloneCategory,
                Timestamp = DateTime.UtcNow,
                Message = message,
                Tags = "", 
                Level = logLevel.GetPythonEquivelant(),
                MachineName = Environment.MachineName,
                IPAddress = Dns.GetHostEntry(Dns.GetHostName()).AddressList.FirstOrDefault(ip => ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)?.ToString() // TODO: put this into some kind of network service. youll have to have something like that for awareness of other nodes anyways. e.g. where is the database server, what are the render containers, etc.
            };

            _logWriter.Queue(logEntry);
        }

        public bool IsEnabled(LogLevel logLevel)
        {
            return (_filter == null || _filter(_categoryName, logLevel));
        }

        public IDisposable BeginScope<TState>(TState state) => null;
    }
}
