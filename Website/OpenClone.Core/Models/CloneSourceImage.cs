using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class CloneSourceImage
    {
        public int Id { get; set; }
        [JsonIgnore]
        virtual public Clone Clone { get; set; }

        public string FileName { get; set; }
        
        public int Index { get; set; }
    }
}
