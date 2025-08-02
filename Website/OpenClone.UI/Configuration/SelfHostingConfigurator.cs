using System.Security.Cryptography.X509Certificates;

namespace OpenClone.UI.Configuration
{
    /// <summary>
    /// Configures HTTPS support for self-hosting scenarios with automatic SSL certificate loading.
    /// Supports both Let's Encrypt certificates and development fallback.
    /// </summary>
    public class SelfHostingConfigurator
    {
        public static void Configure(WebApplicationBuilder builder)
        {
            // Configure HTTPS directly in ASP.NET
            builder.WebHost.ConfigureKestrel(options =>
            {
                options.ListenAnyIP(80);  // HTTP
                options.ListenAnyIP(443, listenOptions =>
                {
                    // Use self-signed certificate for HTTPS
                    var certPath = "/app/ssl/fullchain.pem";
                    var keyPath = "/app/ssl/privkey.pem";

                    if (File.Exists(certPath) && File.Exists(keyPath))
                    {
                        try
                        {
                            // Load certificate and private key
                            var cert = X509Certificate2.CreateFromPemFile(certPath, keyPath);
                            listenOptions.UseHttps(cert);
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"SSL certificate error: {ex.Message}");
                            Console.WriteLine("Falling back to development certificate...");
                            listenOptions.UseHttps();
                        }
                    }
                    else
                    {
                        // Fallback to development certificate if SSL files don't exist
                        Console.WriteLine("SSL files not found, using development certificate...");
                        listenOptions.UseHttps();
                    }
                });
            });
        }
    }
}
