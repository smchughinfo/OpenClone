using Microsoft.AspNetCore.Identity;
using OpenClone.Core.Models;

namespace OpenClone.UI.Configuration
{
    public class RoleConfigurator
    {
        public static async Task Configure(WebApplication app)
        {
            using (var scope = app.Services.CreateScope())
            {
                await ConfigureRoles(scope);
            }
        }

        private static async Task ConfigureRoles(IServiceScope scope)
        {
            var roleManager = scope.ServiceProvider.GetService<RoleManager<IdentityRole>>();

            // List of roles to create.
            string[] roles = new string[] { "Admin", "SuperUser" };

            foreach (var roleName in roles)
            {
                // Check if the role exists.
                var roleExists = await roleManager.RoleExistsAsync(roleName);

                // If not, create the role.
                if (!roleExists)
                {
                    await roleManager.CreateAsync(new IdentityRole(roleName));
                }
            }
        }
    }
}
