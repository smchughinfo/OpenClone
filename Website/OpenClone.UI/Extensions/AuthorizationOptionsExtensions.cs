using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace OpenClone.UI.Extensions
{
    public static class AuthorizationOptionsExtensions
    {
        public static void AddComputedPolicy(this AuthorizationOptions authorizationOptions, string policyName, Func<ClaimsPrincipal, bool> computedPolicy)
        {
            authorizationOptions.AddPolicy(policyName, policy =>
            {
                policy.RequireAssertion(context =>
                {
                    return computedPolicy(context.User);
                });
            });
        }
    }
}
