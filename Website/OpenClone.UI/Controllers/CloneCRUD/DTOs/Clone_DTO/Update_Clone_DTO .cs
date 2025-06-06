using OpenClone;
using OpenClone.Core.Models;
using OpenClone.UI;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD;
using OpenClone.UI.Controllers.CloneCRUD.DTOs;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using System.ComponentModel.DataAnnotations;

namespace OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO
{
    public class Update_Clone_DTO : Clone_DTO
    {
        [Required]
        public int Id { get; set; }
    }
}
