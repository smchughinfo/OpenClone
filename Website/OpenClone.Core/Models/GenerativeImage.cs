using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class GenerativeImage : Embedding
    {
        public int Id { get; set; }
        virtual public GenerativeImage? SourceImage { get; set; }

        public string Path => $"/OpenCloneFS/GenerativeImages/{(SourceImage == null ? Id : SourceImage.Id)}.png";
    }
}
