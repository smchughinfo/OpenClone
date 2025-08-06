using Microsoft.AspNetCore.Identity;
using OpenClone.Core.Models;
using OpenClone.Services.Services;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services;
using static System.Formats.Asn1.AsnWriter;

namespace OpenCloneUI.Configuration
{
    public static class DevDataConfigurator
    {
        public static async Task Configure(WebApplication app)
        {
            using (var scope = app.Services.CreateScope())
            {
                await ConfigureRolesAndClaims(scope);
                await CreateCloneVoices(scope);
            }
        }

        private static async Task CreateCloneVoices(IServiceScope scope)
        {
            await EnsureCloneHasVoice(2, scope);
        }

        private static async Task EnsureCloneHasVoice(int cloneId, IServiceScope scope)
        {
            await scope.ServiceProvider.GetService<ElevenLabsService>().DeleteUnusedVoices();

            var cloneCRUDService = scope.ServiceProvider.GetService<CloneCRUDService>();
            var cloneMetadataService = scope.ServiceProvider.GetService<CloneMetadataService>();
            var configurationService = scope.ServiceProvider.GetService<ConfigurationService>();

            Clone devClone = null;
            try { devClone = cloneCRUDService.GetClone(cloneId); }
            catch { }

            if (devClone != null && devClone.VoiceId == null)
            {
                var cloneAudioFilePath = cloneMetadataService.GetCloneAudioSample(cloneId);

                // Read the file to ensure it exists or to perform any operations before updating
                byte[] fileData = null;
                using (FileStream stream = new FileStream(cloneAudioFilePath, FileMode.Open, FileAccess.Read))
                {
                    fileData = new byte[stream.Length];
                    await stream.ReadAsync(fileData, 0, (int)stream.Length);
                } // FileStream is disposed here

                // Now that the stream is disposed, you can safely call UpdateClone
                var audioSample = new MemoryStream(fileData);
                await cloneCRUDService.UpdateClone(devClone, null, audioSample);
            }
        }


        private static async Task ConfigureRolesAndClaims(IServiceScope scope)
        {
            var roleManager = scope.ServiceProvider.GetService<RoleManager<IdentityRole>>();
            var userManager = scope.ServiceProvider.GetService<UserManager<ApplicationUser>>();

            CreateRoles(roleManager).Wait();

            var devAdminUser = userManager.Users.SingleOrDefault(u => u.UserName == "seanmchugh513@gmail.com");
            if (devAdminUser != null)
            {
                await userManager.AddToRoleAsync(devAdminUser, "Admin");

                var devAdminUserClaims = await userManager.GetClaimsAsync(devAdminUser);
                if (!devAdminUserClaims.Any(c => c.Type == "CanCreateQuestions"))
                {
                    await userManager.AddClaimAsync(devAdminUser, new System.Security.Claims.Claim("CanCreateQuestions", ""));
                }
            }
        }

        private static async Task CreateRoles(RoleManager<IdentityRole> roleManager)
        {
            // List of roles to create.
            string[] roles = new string[] { "Admin", "SuperUser", "User" };

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
