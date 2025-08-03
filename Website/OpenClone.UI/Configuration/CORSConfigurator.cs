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
                    policy.SetIsOriginAllowed(origin => 
                        {
                            if (string.IsNullOrEmpty(origin)) return false;
                            var uri = new Uri(origin);
                            return uri.Host == "clonezone.me" || uri.Host.EndsWith(".clonezone.me");
                        })
                          .AllowAnyMethod()
                          .AllowAnyHeader()
                          .AllowCredentials();
                });
            });
        }
    }
}
