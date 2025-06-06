using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.UI.Configuration;
using OpenClone.UI.Configuration.Services;
using System.Security.Claims;

namespace OpenClone.UI.Extensions
{
    public static class ClaimsPrincipalExtensions
    {
        public static string GetId(this ClaimsPrincipal principal)
        {
            return principal.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        public static int GetActiveCloneId(this ClaimsPrincipal principal)
        {
            using (var scope = StaticServiceProvider.ServiceProvider.CreateScope())
            {
                var applicationUserService = scope.ServiceProvider.GetService<ApplicationUserService>();
                var userId = GetId(principal);
                return applicationUserService.GetActiveCloneId(userId).Value;
            }
        }

        /*public static string GetLoggedInUserName(this ClaimsPrincipal principal)
        {
            if (principal == null)
                throw new ArgumentNullException(nameof(principal));

            return principal.FindFirstValue(ClaimTypes.Name);
        }

        public static string GetLoggedInUserEmail(this ClaimsPrincipal principal)
        {
            if (principal == null)
                throw new ArgumentNullException(nameof(principal));

            return principal.FindFirstValue(ClaimTypes.Email);
        }*/
    }
}
