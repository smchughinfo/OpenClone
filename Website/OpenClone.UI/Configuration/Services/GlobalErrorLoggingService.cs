using OpenClone.Core;
using OpenClone.Services.Services;
using OpenClone.Services.Services;
using OpenClone.UI.Extensions;

namespace OpenClone.UI.Configuration.Services
{
    public class GlobalErrorLoggingService
    {
        private readonly ILogger _logger;
        public GlobalErrorLoggingService(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger(GlobalVariables.OpenCloneCategory);
        }

        // TODO: THIS NEEDS UNIT TESTS!!! I think this is the most complicated function in the entire program. This is a perfect candidate for unit tests.
        // TODO: you should add flags to the ancillary apps to tell them not to do any logging either.
        public string GenerateAndLogErrorInformation(HttpContext context, Exception exception, bool sendTopExceptionMessageToUser, bool? forceLog)
        {
            var errorMessage = "";
            var errorId = Guid.NewGuid().ToString();

            // this operates on the assumption that the active clone is where the error comes from. which should usually be true. except, for example, during clone creation. in which case forceLog can be supplied as a parameter to the OpenCloneException object to determine whether or not to log. Regular uncaught exceptions (that is, exceptions not raised via throw new OpenCloneException(...) don't have the forceLogOverride property though and so in this function they will operate on the assumption that the error is an active clone. which is preferred because not logging should be the default. logging should only be allowed when the user chooses to allow logging. and since logging is done on a per clone basis, we have to check what their active clone is. there is, of course the case where there is no active clone yet in which case there is no need to worry about logging as there would be no sensitive/personal information to log. Now, during creation of the users very first clone there would be no active clone and so its critical that the create clone function sets the appropriate value for forceLogOverride
            var logError = false;
            int? activeCloneId = null;
            if (!forceLog.HasValue)
            {
                activeCloneId = context.User.GetId() == null ? null : context.RequestServices.GetService<ApplicationUserService>().GetActiveCloneId(context.User.GetId());
                logError = activeCloneId == null ? true : context.RequestServices.GetService<CloneCRUDService>().GetClone(activeCloneId.Value).AllowLogging;
            }
            else
            {
                logError = forceLog.Value;
            }

            var logToggleNote = forceLog.HasValue ? "" : "(use the clone manager page to turn logging off)";
            errorMessage += "An error occured.";
            errorMessage += (logError ? $" The error id is {errorId}. This error was logged {logToggleNote}." : " Logging is disabled by default for privacy. Check the clone manager page to enable logging. Once logging is enabled the next time you get this error an error id will be shown.") + $" For help, email your error id to {GlobalVariables.HelpEmailAddress}.";
            errorMessage += sendTopExceptionMessageToUser ? $" The error is:\n\n{exception.Message}" : "";

            if (logError)
            {
                var cloneIdToLog = activeCloneId == null ? "null" : activeCloneId.Value.ToString();
                var detailedErrorMessage = $"ErrorId: {errorId}";
                detailedErrorMessage += $"\nCloneId: {cloneIdToLog}";
                detailedErrorMessage += $"\nException: " + exception.Message;
                detailedErrorMessage += "\nInner Exception: " + (exception.InnerException == null ? "null" : exception.InnerException.Message);
                detailedErrorMessage += "\n\nCallstack: " + exception.StackTrace;
                _logger.LogError(detailedErrorMessage);
            }

            return errorMessage;
        }
    }
}
