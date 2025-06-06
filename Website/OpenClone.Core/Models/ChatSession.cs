using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using OpenClone.Core.Models.Enums;

namespace OpenClone.Core.Models
{
    public class ChatSession
    {
        public int Id { get; set; }
        public int CloneId { get; set; }
        virtual public Clone Clone { get; set; }
        virtual public ICollection<ChatMessage> ChatMessages { get; set; } = new List<ChatMessage>();
    }
}
