using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using OpenClone.Core.Data;
using OpenClone.Core.Extensions;
using OpenClone.Core.Models;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using static System.Formats.Asn1.AsnWriter;

namespace OpenClone.Core.Services.Logging
{
    public class LogWriter
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private ConcurrentQueue<LogEntry> _logs = new ConcurrentQueue<LogEntry>();
        private int runNumber;
        public LogWriter(IServiceScopeFactory scopeFactory)
        {
            _scopeFactory = scopeFactory;
            UpdateRunCount();
            Task.Run(() => RunWriteQueue());
        }

        private void UpdateRunCount()
        {
            using (var scope = _scopeFactory.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<LogDbContext>();
                var mostRecentLogEntry = dbContext.LogEntries
                    .OrderByDescending(l => l.Timestamp)
                    .FirstOrDefault(l => l.ApplicationName == GlobalVariables.OpenCloneCategory);
                var mostRecentRun = mostRecentLogEntry == null ? 0 : mostRecentLogEntry.RunNumber;
                runNumber = mostRecentRun + 1;

                dbContext.LogEntries.Add(new LogEntry
                {
                    ApplicationName = GlobalVariables.OpenCloneCategory,
                    RunNumber = runNumber,
                    OpenCloneLog = true,
                    Timestamp = DateTime.UtcNow,
                    Message = "Website - Run Number Incremented",
                    Tags = "",
                    Level = LogLevel.Information.GetPythonEquivelant(),
                    MachineName = Environment.MachineName,
                    IPAddress = Dns.GetHostEntry(Dns.GetHostName()).AddressList.FirstOrDefault(ip => ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)?.ToString()
                });
                dbContext.SaveChanges();
            }
        }

        public void Queue(LogEntry logEntry)
        {
            logEntry.RunNumber = runNumber;
            _logs.Enqueue(logEntry);
        }

        private async Task RunWriteQueue()
        {
            while (true)
            {
                await Task.Delay(1000);
                await Flush();
            }
        }

        public async Task Flush()
        {
            List<LogEntry> logsToWrite = new List<LogEntry>();
            while (_logs.TryDequeue(out var logEntry))
            {
                logsToWrite.Add(logEntry);
            }

            if (logsToWrite.Any())
            {
                using (var scope = _scopeFactory.CreateScope())
                {
                    var dbContext = scope.ServiceProvider.GetRequiredService<LogDbContext>();
                    await dbContext.LogEntries.AddRangeAsync(logsToWrite); // Add the dequeued log entries
                    await dbContext.SaveChangesAsync();
                }
            }
        }

    }
}
