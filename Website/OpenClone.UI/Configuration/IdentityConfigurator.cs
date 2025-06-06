using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using OpenClone.Core.Models;
using System.Text;

namespace OpenCloneUI.Configuration
{
    public static class IdentityConfigurator
    {
        public static void Configure(WebApplicationBuilder builder)
        {
            // GOOGLE
            builder.Services.AddAuthentication()
             .AddGoogle(googleOptions =>
            {
                googleOptions.ClientId = Environment.GetEnvironmentVariable("OpenClone_GoogleClientId");
                googleOptions.ClientSecret = Environment.GetEnvironmentVariable("OpenClone_GoogleClientSecret");
            }).AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options =>
            {
                var secretKey = Environment.GetEnvironmentVariable("OpenClone_JWT_SecretKey");
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = Environment.GetEnvironmentVariable("OpenClone_JWT_Issuer"),
                    ValidAudience = Environment.GetEnvironmentVariable("OpenClone_JWT_Audience"),
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
                };
            });
             
            // Configures default identity with confirmed accounts, role management, and Entity Framework Core data persistence.
            builder.Services.AddDefaultIdentity<ApplicationUser>(options => options.SignIn.RequireConfirmedAccount = true)
            .AddRoles<IdentityRole>()
            .AddEntityFrameworkStores<ApplicationDbContext>();

            // PASSWORD 
            builder.Services.Configure<IdentityOptions>(options =>
            {
                options.Password.RequireDigit = false;
                options.Password.RequiredLength = 6;
                options.Password.RequireLowercase = false;
                options.Password.RequireNonAlphanumeric = false;
                options.Password.RequireUppercase = false;
            });

            // This sets up DI for IHttpContextAccessor so you can get ASPNetUser.Id in service layer without having to pass anything in. https://stackoverflow.com/a/52135130
            builder.Services.AddHttpContextAccessor(); 
        }
    }
}
