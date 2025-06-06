using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.Build.Framework;
using Microsoft.Extensions.DependencyInjection;
using OpenClone.Authorization;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.UI.Configuration;
using OpenClone.UI.Configuration.Services;
using OpenClone.UI.Extensions;
using System.Security.Claims;
using static System.Formats.Asn1.AsnWriter;

namespace OpenCloneUI.Configuration
{
    public class PolicyConfigurator
    {
        public static void Configure(WebApplicationBuilder builder)
        {
            AddComputedPolicy(builder, "HasActiveClone", (serviceScope, user) =>
            {
                var applicationUserService = serviceScope.ServiceProvider.GetService<ApplicationUserService>();
                var applicationUser = applicationUserService.GetApplicationUser(user.Identity.Name);
                return applicationUser.ActiveCloneId != null;
            });

            builder.Services.AddAuthorization(options =>
            {
                options.AddPolicy("NiceUser", policy => policy.RequireClaim("CanCreateQuestions"));
            });

            builder.Services.AddScoped<IAuthorizationHandler, DeleteQuestionAuthorizationHandler>();
        }

        static void AddComputedPolicy(WebApplicationBuilder builder, string policyName, Func<IServiceScope, ClaimsPrincipal, bool> computedPolicy)
        {
            builder.Services.AddAuthorization(options =>
            {
                options.AddComputedPolicy(policyName, user =>
                {
                    if(user.Identity.Name == null)
                    {
                        return false; // TODO: check logging to make sure unlogged in users dont get logged as having failed first computed policy to execute this code
                    }

                    using (var scope = StaticServiceProvider.ServiceProvider.CreateScope())
                    {
                        return computedPolicy(scope, user);
                    }
                });
            });
        }
    }
}
