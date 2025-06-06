using OpenClone;
using OpenClone.Core.Models;
using OpenClone.UI;
using OpenClone.UI.Attributes;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD;
using OpenClone.UI.Controllers.CloneCRUD.DTOs;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using System.ComponentModel.DataAnnotations;

namespace OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO
{
    public class Clone_DTO
    {
        public IFormFile? CloneImage { get; set; }
        public IFormFile? AudioSample { get; set; }
        [Required]
        [NoWhitespaceOnly]
        public string FirstName { get; set; }
        public string? LastName { get; set; }
        public string? NickName { get; set; }
        public string? Age { get; set; }
        public string? Biography { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? Occupation { get; set; }
        public bool? MakePublic { get; set; }
        public bool? AllowLogging { get; set; }
        [Required]
        public int DeepFakeMode { get; set; }
    }
}
