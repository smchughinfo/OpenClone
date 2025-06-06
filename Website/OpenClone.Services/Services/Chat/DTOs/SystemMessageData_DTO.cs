using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.Chat.DTOs
{
    public class SystemMessageData_DTO
    {
        public string Category { get; set; }
        public string Key { get; set; }
        public string Value { get; set; }
        public bool Populated { get; set; }
    }
}
