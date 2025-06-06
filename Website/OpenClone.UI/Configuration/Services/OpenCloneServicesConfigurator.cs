using OpenClone.UI;
using OpenClone.UI.Configuration.Services;
using OpenCloneUI;
using OpenCloneUI.Configuration;

namespace OpenClone.UI.Configuration.Services
{
    public static class OpenCloneServicesConfigurator
    {
        public static void Configure(WebApplicationBuilder webApplicationBuilder)
        {
            ConfigureCoreServices(webApplicationBuilder);
            ConfigureServicesServices(webApplicationBuilder);
            ConfigureUIServices(webApplicationBuilder);
        }

        public static void ConfigureCoreServices(WebApplicationBuilder webApplicationBuilder)
        {
            var openCloneLogLevel = (LogLevel)Enum.Parse(typeof(LogLevel), System.Environment.GetEnvironmentVariable("OpenClone_OpenCloneLogLevel")); // TODO: these environment variables shouldl ideally be in the configuration service but thats not avaialable early in program.cs. maybe put them in globalvriables? idk but they should all be in one place.
            var systemLogLevel = (LogLevel)Enum.Parse(typeof(LogLevel), System.Environment.GetEnvironmentVariable("OpenClone_SystemLogLevel"));
            Core.ServicesSetup.DoSetup(webApplicationBuilder.Services, openCloneLogLevel, systemLogLevel);
        }

        public static void ConfigureServicesServices(WebApplicationBuilder webApplicationBuilder)
        {
            OpenClone.Services.ServicesSetup.DoSetup(webApplicationBuilder.Services);
        }

        public static void ConfigureUIServices(WebApplicationBuilder webApplicationBuilder)
        {
            webApplicationBuilder.Services.AddScoped<JWTokenGenerator>();

            // third party
            webApplicationBuilder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies()); // this also gets done in the Services project, although doing so is redundtant when used with the Services project

            // error logging
            webApplicationBuilder.Services.AddSingleton<GlobalErrorLoggingService>();
        }
    }
}
