using Microsoft.EntityFrameworkCore;
using OpenClone.Core.Extensions;
using OpenClone.Core.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Data
{
    public class LogDbContext : DbContext
    {
        public DbSet<LogEntry> LogEntries { get; set; }
        public LogDbContext(DbContextOptions<LogDbContext> options) : base(options)
        {

        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            SetupLogEntry(modelBuilder);
            modelBuilder.UseSnakeCase();
        }

        private void SetupLogEntry(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<LogEntry>()
                .ToTable("log");
        }
    }
}
