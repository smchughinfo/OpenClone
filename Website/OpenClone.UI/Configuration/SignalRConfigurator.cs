using Microsoft.AspNetCore.SignalR;
using OpenClone.UI.Hubs;

namespace OpenClone.UI.Configuration
{
    public class SignalRConfigurator
    {
        public static void ConfigureErrorHandling(WebApplicationBuilder builder)
        {
            builder.Services.AddSignalR(options =>
            {
                options.AddFilter<ExceptionHandlingFilter>();  
            });
        }

        public static void ConfigureRoutes(WebApplication app)
        {
            app.MapHub<ChatHub>("/chatHub");

        }
    }
}
