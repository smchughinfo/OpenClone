using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Data
{
    // This class allows you to build this solution in server 0. 
    // Design-time factory for Entity Framework migrations. EF Core uses this factory to create
    // DbContext instances during design-time operations (like migrations) when the normal
    // dependency injection container is not available. This bypasses DI and directly creates
    // the DbContext with the appropriate connection string based on environment variables.
    public class LogDbContextFactory : IDesignTimeDbContextFactory<LogDbContext>
    {
        public LogDbContext CreateDbContext(string[] args)
        {
            var doingMigration = Environment.GetEnvironmentVariable("OpenClone_EF_MIGRATION") == "True";
            var connectionString = doingMigration
                ? Environment.GetEnvironmentVariable("OpenClone_LogDbConnection_Super")
                : Environment.GetEnvironmentVariable("OpenClone_LogDbConnection");

            var optionsBuilder = new DbContextOptionsBuilder<LogDbContext>();
            optionsBuilder.UseNpgsql(connectionString);

            return new LogDbContext(optionsBuilder.Options);
        }
    }
}
