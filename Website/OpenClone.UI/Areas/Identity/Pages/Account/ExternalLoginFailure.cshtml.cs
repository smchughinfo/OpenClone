using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace OpenClone.Areas.Identity.Pages.Account
{
    [AllowAnonymous]
    public class ExternalLoginFailureModel : PageModel
    {
        public string ErrorMessage { get; set; }
        public string TechnicalError { get; set; }
        public bool ShowTechnicalDetails { get; set; }

        public void OnGet(string error = null, string description = null, string technical = null)
        {
            // Determine environment for technical details
            ShowTechnicalDetails = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") == "Development";

            // Set user-friendly error message
            ErrorMessage = GetUserFriendlyMessage(error, description);
            
            // Store technical error for debugging
            TechnicalError = technical ?? error ?? "Unknown authentication error";
        }

        private string GetUserFriendlyMessage(string error, string description)
        {
            return error?.ToLower() switch
            {
                "access_denied" => "You cancelled the Google sign-in process. Please try again if you want to sign in.",
                "unauthorized" => "Google authentication failed. Please check your account permissions and try again.",
                "invalid_request" => "There was a problem with the sign-in request. Please try again.",
                "temporarily_unavailable" => "Google's authentication service is temporarily unavailable. Please try again in a few minutes.",
                "server_error" => "Google encountered an error while processing your sign-in. Please try again.",
                "invalid_client" => "There's a configuration issue with Google authentication. Please contact support.",
                _ when !string.IsNullOrEmpty(description) => description,
                _ => null // Will show the default message in the view
            };
        }
    }
}