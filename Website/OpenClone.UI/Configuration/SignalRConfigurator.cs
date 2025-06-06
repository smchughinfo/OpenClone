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
            // IMPORTANT NOTE - WHEN YOU ADD A HUB HERE YOU MUST MANUALLY ADD IT TO EXCEPTIONHANDLINGFILTER.CS OTHERWISE IT WONT CATCH ERRORS
            app.MapHub<ChatHub>("/chatHub");
            // IMPORTANT NOTE - WHEN YOU ADD A HUB HERE YOU MUST MANUALLY ADD IT TO EXCEPTIONHANDLINGFILTER.CS OTHERWISE IT WONT CATCH ERRORS

        }
    }
}
