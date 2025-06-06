using Azure.Core;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.FileProviders;
using OpenClone;
using OpenClone.Services;
using OpenClone.UI;
using OpenClone.UI.Configuration.RequestMiddleware;
using OpenClone.UI.Extensions;
using static System.Net.Mime.MediaTypeNames;

namespace OpenClone.UI.Configuration.RequestMiddleware
{
    public class OpenCloneFSMiddleware
    {
        private readonly RequestDelegate _next;

        public OpenCloneFSMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task Invoke(HttpContext context)
        {
            var isOpenCloneFSRequest = IsOpenCloneFSRequest(context.Request);
            if (isOpenCloneFSRequest)
            {
                var hasAccess = HasAccess(context);
                if (hasAccess)
                {
                    await _next(context); // User has access, proceed
                }
                else
                {
                    context.Response.StatusCode = 403; // Forbidden
                    return;
                }
            }
            else
            {
                await _next(context); // Not accessing protected content, proceed
            }
        }

        bool IsOpenCloneFSRequest(HttpRequest request)
        {
            var url = request.Path.ToString();
            return url.StartsWith("/OpenCloneFS");
        }

        bool HasAccess(HttpContext context)
        {
            return true; // todo: remove
            var url = context.Request.Path.ToString();
            var cloneId = context.User.GetActiveCloneId();
            var urlComponents = url.Split('/');
            var component1Good = urlComponents[1] == "OpenCloneFS";
            var component2Good = urlComponents[2] == cloneId.ToString();

            return component1Good && component2Good;
        }

        public static void SetupURL(WebApplication app)
        {
            var extensionProvider = new FileExtensionContentTypeProvider();
            extensionProvider.Mappings[".m3u8"] = "application/vnd.apple.mpegurl";

            app.UseStaticFiles(new StaticFileOptions
            {
                FileProvider = new PhysicalFileProvider(Environment.GetEnvironmentVariable("OpenClone_OpenCloneFS")),
                RequestPath = "/OpenCloneFS", // This is the request path in the URL where the files will be available.
                ContentTypeProvider = extensionProvider
            }); // Enables serving static files (e.g., HTML, CSS, images) from the wwwroot folder.

        }
    }
}
