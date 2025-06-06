using Elfie.Serialization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authorization.Infrastructure;
using Microsoft.AspNetCore.Identity;
using OpenClone.Core.Models;

namespace OpenClone.Authorization
{
    public class DeleteQuestionAuthorizationHandler
        : AuthorizationHandler<OperationAuthorizationRequirement, ClaimAndPolicyQuestionExampleToBeDeleted>

    {
        UserManager<ApplicationUser> _userManager;

        public DeleteQuestionAuthorizationHandler(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }

        protected override Task
                HandleRequirementAsync(AuthorizationHandlerContext context,
                                        OperationAuthorizationRequirement requirement,
                                        ClaimAndPolicyQuestionExampleToBeDeleted question)
        {
            if (context.User == null || question == null)
            {
                return Task.CompletedTask;

                /* https://learn.microsoft.com/en-us/aspnet/core/security/authorization/secure-data?view=aspnetcore-7.0
                 * Return Task.CompletedTask when requirements aren't met. Returning Task.CompletedTask without a prior call to context.Success or context.Fail, is not a success or failure, it allows other authorization handlers to run.
                    If you need to explicitly fail, call context.Fail.
                 */
            }

            //var identityUser = _userManager.GetUs .GetUserId(context.User.Identity);
            var canCreateQuestions = context.User.HasClaim("CanCreateQuestions", "");
            var isOwner = question.Owner == context.User.Identity.Name;
            if (canCreateQuestions && isOwner)
            {
                context.Succeed(requirement);
            }

            return Task.CompletedTask;
        }
    }
}
