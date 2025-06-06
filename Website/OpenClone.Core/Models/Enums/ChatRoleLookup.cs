using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Models.Enums
{
    public enum ChatRole { System = 1, User, Assistant }

    public class ChatRoleLookup : EnumLookup<ChatRole>
    {
        public ChatRoleLookup() { }
        public ChatRoleLookup(int id) : base(id) { }
        public ChatRoleLookup(string enumName) : base(enumName) { }
    }
}
