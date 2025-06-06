using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OpenClone.Core;
using OpenClone.Services.Services;
using OpenClone.UI.Extensions;
using System.ComponentModel.DataAnnotations;

namespace OpenClone.UI.Controllers
{
    [ApiController]
    [Authorize]
    public abstract class _OpenCloneAPIController : ControllerBase
    {
        protected ApplicationUserService _applicationUserService
        {
            get
            {
                return HttpContext.RequestServices.GetService<ApplicationUserService>();
            }
        }
        protected int _activeCloneId
        {
            get { return _applicationUserService.GetActiveCloneId(User.GetId()).Value; }
        }

        protected string RemoveLTGT(string value)
        {
            return value == null ? null : value
                .Replace("<", "&lt;")
                .Replace(">", "&gt;");
        }
    }
}
