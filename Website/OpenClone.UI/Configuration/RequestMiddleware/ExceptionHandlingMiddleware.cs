namespace OpenClone.UI.Configuration.RequestMiddleware
{
    using Microsoft.AspNetCore.Http;
    using OpenClone.Core;
    using OpenClone.Services.Services;
    using OpenClone.UI.Configuration.Services;
    using OpenClone.UI.Extensions;
    using OpenCvSharp;
    using System;
    using System.Net;
    using System.Threading.Tasks;

    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly GlobalErrorLoggingService _globalErrorLoggingService;
        public ExceptionHandlingMiddleware(RequestDelegate next, GlobalErrorLoggingService globalErrorLoggingService)
        {
            _next = next;
            _globalErrorLoggingService = globalErrorLoggingService;
        }

        public async Task InvokeAsync(HttpContext httpContext)
        {
            try
            {
                await _next(httpContext);
            }
            catch (OpenCloneException ex)
            {
                await HandleExceptionAsync(httpContext, ex, ex.SendDetailsToUser, ex.ForceLog);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(httpContext, ex, false);
            }
        }

        private Task HandleExceptionAsync(HttpContext context, Exception exception, bool sendDetailsToUser, bool? forceLog = null)
        {
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

            var errorMessage = _globalErrorLoggingService.GenerateAndLogErrorInformation(context, exception, sendDetailsToUser, forceLog);

            var response = new
            {
                StatusCode = context.Response.StatusCode,
                Message = "500 Internal Server Error",
                Detailed = errorMessage
            };

            var jsonResponse = System.Text.Json.JsonSerializer.Serialize(response);

            return context.Response.WriteAsync(jsonResponse);
        }
    }

}
