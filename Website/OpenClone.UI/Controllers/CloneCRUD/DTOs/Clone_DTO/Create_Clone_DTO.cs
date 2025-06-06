using System.ComponentModel.DataAnnotations;
using OpenClone;
using OpenClone.UI;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD;
using OpenClone.UI.Controllers.CloneCRUD.DTOs;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;

namespace OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO
{
    public class Create_Clone_DTO : Clone_DTO
    {
        [Required]
        public IFormFile CloneImage { get; set; }
        [Required]
        public IFormFile? AudioSample { get; set; }
    }
}
