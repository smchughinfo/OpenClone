using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI.DTOs
{
    internal class Usage
    {
        public int PromptTokens { get; set; }
        public int TotalTokens { get; set; }
    }
}
