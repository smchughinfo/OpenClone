using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection; // Ensure this namespace is included
using OpenClone.Services.Services;
using OpenCvSharp;

namespace OpenClone.UI.Hubs
{
    public abstract class _OpenCloneHub : Hub
    {
        private readonly ApplicationUserService _applicationUserService;

        public _OpenCloneHub(ApplicationUserService applicationUserService)
        {
            _applicationUserService = applicationUserService;
        }

        public int _activeCloneId
        {
            get { return _applicationUserService.GetActiveCloneId(Context.UserIdentifier).Value; }
        }
    }
}
