using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class LogEntry
    {
        [Key]
        public int LogId { get; set; }
        public int RunNumber { get; set; }
        public string ApplicationName { get; set; }
        public bool OpenCloneLog { get; set; }
        public DateTime Timestamp { get; set; }
        public string Message { get; set; }
        public string Tags { get; set; }
        public string Level { get; set; }
        public string MachineName { get; set; }
        public string IPAddress { get; set; }
    }
}
