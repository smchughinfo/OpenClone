using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using OpenClone.Core.Data;
using OpenClone.Core.Services.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core
{
    public class ServicesSetup
    {
        public static void DoSetup(IServiceCollection services, LogLevel openCloneLogLevel, LogLevel systemLogLevel)
        {
            // LogWriter
            services.AddSingleton<LogWriter>();

            // LoggerProvider
            services.AddLogging(builder =>
            {
                // this Func is the logic to determine which logs to log based on log level
                Func<string, LogLevel, bool> filter = (category, level) => {
                    if (category == GlobalVariables.OpenCloneCategory)
                    {
                        return level >= openCloneLogLevel;
                    }
                    return level >= systemLogLevel;
                };
                var serviceProvider = services.BuildServiceProvider();
                var dbLoggerProvider = new LoggerProvider(filter, serviceProvider);

                // IMPORTANT NOTE: this disaster cost you 1 weekend. This is necessary for dotnet ef migrations add foo too work. See DoMigrations.ps1 in the database generat and populate program (*note - adding this for visibility -> TODO: IMPORTANT NOTE)
                if (string.IsNullOrEmpty(Environment.GetEnvironmentVariable("OpenClone_EF_MIGRATION")))
                {
                    builder.AddProvider(dbLoggerProvider);
                }
            });
        }
    }
}
