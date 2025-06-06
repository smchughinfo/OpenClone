using Microsoft.AspNetCore.Mvc;

namespace OpenClone.UI.Controllers.SignalR
{
    [Route("api/[controller]")]
    public class SignalRController : _OpenCloneAPIController
    {
        JWTokenGenerator _jwtGenerator;

        public SignalRController(JWTokenGenerator jwtGenerator) { 
            _jwtGenerator = jwtGenerator;
        }

        [HttpGet("GetJwtToken")]
        public IActionResult GetJwtToken()
        {
            return Ok(_jwtGenerator.GenerateJwtToken());    
        }
    }
}
