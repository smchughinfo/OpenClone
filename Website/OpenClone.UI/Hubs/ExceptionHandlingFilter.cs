using Microsoft.AspNetCore.SignalR;
using OpenClone;
using OpenClone.Core;
using OpenClone.Services.Services;
using OpenClone.UI;
using OpenClone.UI.Configuration.Services;
using OpenClone.UI.Extensions;
using OpenClone.UI.Hubs;
using System.Security.Claims;

namespace OpenClone.UI.Hubs
{
    public class ExceptionHandlingFilter : IHubFilter
    {
        private readonly ILogger _logger;
        private readonly IHubContext<ChatHub> _hubContext;  // Use the base Hub context
        private readonly GlobalErrorLoggingService _globalErrorLoggingService;

        public ExceptionHandlingFilter(ILoggerFactory loggerFactory, IHubContext<ChatHub> hubContext, ApplicationUserService applicationUserService, GlobalErrorLoggingService globalErrorLoggingService)
        {
            _logger = loggerFactory.CreateLogger(GlobalVariables.OpenCloneCategory);
            _hubContext = hubContext;
            _globalErrorLoggingService = globalErrorLoggingService;
        }

        public async ValueTask<object> InvokeMethodAsync(HubInvocationContext invocationContext, Func<HubInvocationContext, ValueTask<object>> next)
        {
            try
            {
                return await next(invocationContext);
            }
            catch (Exception ex)
            {
                var httpContext = invocationContext.Context.GetHttpContext();
                var errorMessage = _globalErrorLoggingService.GenerateAndLogErrorInformation(httpContext, ex, false, null);

                // Send error information to the client that caused the exception
                await _hubContext.Clients.Client(invocationContext.Context.ConnectionId)
                                  .SendAsync("ReceiveError", errorMessage);

                throw; // Re-throw the exception if necessary
            }
        }

        private void LogToDatabase(int cloneId, HubInvocationContext invocationContext, Exception ex)
        {
            var errorMessage = $"An error occurred while invoking a method in hub {invocationContext.HubMethodName}";
            errorMessage += $"\n\nCloneId: {cloneId}";
            errorMessage += $"\n\nException: {ex.Message.ToString()}";
            if (ex.InnerException != null)
            {
                errorMessage += $"\n\nInner Exception: {ex.InnerException.Message.ToString()}";
            }
            errorMessage += $"\n\nStackTrace: {ex.StackTrace}";
            _logger.LogError(errorMessage);
        }
    }
}
