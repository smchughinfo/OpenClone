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
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.CloneCRUD;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using OpenClone.UI.Controllers.CloneMetadata;
using OpenClone.UI.Controllers.CloneMetadata;
using OpenClone.UI.Extensions;

namespace OpenClone.UI.Controllers.CloneMetadata
{
    [Route("api/[controller]")]

    public class CloneMetadataController : _OpenCloneAPIController
    {
        CloneMetadataService _cloneMetadataService;

        public CloneMetadataController(CloneMetadataService cloneMetadataService)
        {
            _cloneMetadataService = cloneMetadataService;
        }

        [HttpPost("SetDeepFakeMode")]
        public async Task<IActionResult> SetDeepFakeMode([FromBody] int deepFakeMode)
        {
            await _cloneMetadataService.SetDeepFakeMode(_activeCloneId, deepFakeMode);
            return new OkResult();
        }
    }
}








