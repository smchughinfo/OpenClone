using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class ApplicationUser : IdentityUser
    {
        public int? ActiveCloneId { get; set; }
        virtual public Clone? ActiveClone { get; set; }
    }
}
