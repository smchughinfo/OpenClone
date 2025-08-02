using System.Text.Json.Serialization;

namespace OpenClone.UI.Configuration
{
    public class CORSConfigurator
    {
        public static void Configure(WebApplicationBuilder builder)
        {
            // Configure CORS to allow splash page requests
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("SplashPagePolicy", policy =>
                {
                    policy.WithOrigins("https://clonezone.me", "http://clonezone.me")
                          .AllowAnyMethod()
                          .AllowAnyHeader()
                          .AllowCredentials();
                });
            });
        }
    }
}
