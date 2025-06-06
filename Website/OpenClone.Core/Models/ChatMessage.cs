using OpenClone.Core.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class ChatMessage
    {
        public int Id { get; set; }

        public int ChatSessionId;
        virtual public ChatSession ChatSession { get; set; }
        public DateTime TimeStamp { get; set; }
        public string Message { get; set; }
        public int ChatRoleLookupId { get; set; }
        virtual public ChatRoleLookup ChatRole { get; set; }
    }
}
