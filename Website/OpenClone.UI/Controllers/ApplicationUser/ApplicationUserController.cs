using Microsoft.AspNetCore.Mvc;
using OpenClone.Services.Services;
using OpenClone.UI.Extensions;

namespace OpenClone.UI.Controllers.ApplicationUser
{
    [Route("api/[controller]")]

    public class ApplicationUserController : _OpenCloneAPIController
    {
        ApplicationUserService _applicationUserService;

        public ApplicationUserController(ApplicationUserService applicationUserService)
        {
            _applicationUserService = applicationUserService;
        }

        [HttpGet("GetActiveCloneId")]
        public IActionResult GetActiveCloneId()
        {
            return Ok(_activeCloneId);
        }

        [HttpPost("SetActiveClone")]
        public async Task<IActionResult> SetActiveClone([FromBody] int cloneId)
        {
            await _applicationUserService.SetActiveCloneId(User.GetId(), cloneId);
            return new OkResult();
        }
    }
}
