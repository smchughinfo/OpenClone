using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.Identity.Client;
using OpenClone;
using OpenClone.Core;
using OpenClone.Core.Models;
using OpenClone.Pages;
using OpenClone.Services.Services;
using OpenClone.UI;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using OpenClone.UI.Extensions;
using OpenClone.Services.Services;
using SixLabors.ImageSharp;

namespace OpenClone.UI.Controllers.CloneCRUD
{
    [Route("api/[controller]")]

    public class CloneCRUDController : _OpenCloneAPIController
    {
        CloneCRUDService _cloneCRUDService;
        ApplicationUserService _applicationUserService;
        IMapper _mapper;

        public CloneCRUDController(CloneCRUDService cloneCRUDService, ApplicationUserService applicationUserService, IMapper mapper)
        {
            _cloneCRUDService = cloneCRUDService;
            _applicationUserService = applicationUserService;
            _mapper = mapper;
        }

        [HttpGet("GetClones")]
        public IActionResult GetClones()
        {
            var clones = _cloneCRUDService.GetClones(User.GetId());
            var cloneDTOs = clones.Select(c => _mapper.Map<Get_Clone_DTO>(c)).ToList();
            return Ok(cloneDTOs);
        }

        [HttpGet("GetActiveClone")]
        public async Task<IActionResult> GetActiveClone()
        {
            var activeClone = await _cloneCRUDService.GetActiveClone(User.GetId());
            return Ok(activeClone);
        }

        [HttpPost("CreateClone")]
        public async Task<IActionResult> CreateClone([FromForm] Create_Clone_DTO cloneDto)
        {
            var profileImage = await cloneDto.CloneImage.ToPngImage();
            var audioSample = await cloneDto.AudioSample.ToWav();
            var clone = _mapper.Map<Clone>(cloneDto);
            await _cloneCRUDService.CreateClone(User.GetId(), clone, profileImage, audioSample);

            return new OkResult(); // TODO: just do return Ok(); everywhere 
        }

        [HttpPost("UpdateClone")]
        public async Task<IActionResult> UpdateClone([FromForm] Update_Clone_DTO cloneDto)
        {
            Image profileImage = null;
            if (cloneDto.CloneImage != null)
            {
                profileImage = await cloneDto.CloneImage.ToPngImage();
            }

            Stream audioSample = null;
            if (cloneDto.AudioSample != null)
            {
                audioSample = await cloneDto.AudioSample.ToWav();
            }

            var clone = _mapper.Map<Clone>(cloneDto);
            await _cloneCRUDService.UpdateClone(clone, profileImage, audioSample);

            return new OkResult();
        }

        [HttpPost("DeleteClone")]
        public async Task<IActionResult> DeleteClone([FromBody] int cloneId)
        {
            await _cloneCRUDService.DeleteClone(User.GetId(), cloneId);
            return new OkResult();
        }
    }
}








