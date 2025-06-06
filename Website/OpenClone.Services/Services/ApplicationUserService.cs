using Microsoft.AspNetCore.Identity;
using OpenClone;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services;

namespace OpenClone.Services.Services
{
    public class ApplicationUserService
    {

        ApplicationDbContext _applicationDbContext;

        public ApplicationUserService(ApplicationDbContext applicationDbContext)
        {
            _applicationDbContext = applicationDbContext;
        }

        public ApplicationUser GetApplicationUser(string username)
        {
            return _applicationDbContext.ApplicationUser.Single(u => u.UserName == username);
        }

        public int? GetActiveCloneId(string userId)
        {
            return _applicationDbContext.ApplicationUser.Find(userId).ActiveCloneId;
        }

        public async Task SetActiveCloneId(string userId, int? activeCloneId)
        {
            var user = _applicationDbContext.ApplicationUser.Find(userId);
            user.ActiveCloneId = activeCloneId;
            _applicationDbContext.SaveChanges();
        }
    }
}
