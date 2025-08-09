using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using OpenClone.Core.Models;
using OpenClone.Services.Services;

namespace OpenClone.UI.Middleware
{
    public class OrphanedUserMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IServiceScopeFactory _serviceScopeFactory;

        public OrphanedUserMiddleware(RequestDelegate next, IServiceScopeFactory serviceScopeFactory)
        {
            _next = next;
            _serviceScopeFactory = serviceScopeFactory;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            if (context.User.Identity?.IsAuthenticated == true && context.User.Identity.Name != null)
            {
                using var scope = _serviceScopeFactory.CreateScope();
                var applicationUserService = scope.ServiceProvider.GetRequiredService<ApplicationUserService>();
                var signInManager = scope.ServiceProvider.GetRequiredService<SignInManager<ApplicationUser>>();

                var applicationUser = applicationUserService.GetApplicationUser(context.User.Identity.Name);
                
                if (applicationUser == null)
                {
                    await signInManager.SignOutAsync();
                    context.Response.Redirect("/");
                    return;
                }
            }

            await _next(context);
        }
    }
}