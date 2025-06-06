using Microsoft.EntityFrameworkCore;
using OpenClone.Core.Data;
using Pgvector.EntityFrameworkCore;
using Pgvector.Npgsql;

namespace OpenCloneUI.Configuration
{
    public static class DbContextConfigurator
    {
        public static void Configure(WebApplicationBuilder builder)
        {
            var doingMigration = Environment.GetEnvironmentVariable("OpenClone_EF_MIGRATION") == "True";
            var defaultConnection = doingMigration ? Environment.GetEnvironmentVariable("OpenClone_DefaultConnection_Super") : Environment.GetEnvironmentVariable("OpenClone_DefaultConnection");
            var logConnection = doingMigration ? Environment.GetEnvironmentVariable("OpenClone_LogDbConnection_Super") : Environment.GetEnvironmentVariable("OpenClone_LogDbConnection");
            builder.Services.AddDbContext<ApplicationDbContext>(options =>
                options.UseNpgsql(defaultConnection, o=> o.UseVector())
            );
            builder.Services.AddDbContext<LogDbContext>(options =>
                options.UseNpgsql(logConnection)
            );
        }
    }
}
