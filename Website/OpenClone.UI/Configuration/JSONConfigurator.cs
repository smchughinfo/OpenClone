using System.Text.Json.Serialization;

namespace OpenClone.UI.Configuration
{
    public static class JSONConfigurator
    {
        public static void Configure(WebApplicationBuilder builder)
        {
            builder.Services.AddControllers().AddJsonOptions(options =>
            {
                options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
                options.JsonSerializerOptions.WriteIndented = true;
            });
        }
    }
}
