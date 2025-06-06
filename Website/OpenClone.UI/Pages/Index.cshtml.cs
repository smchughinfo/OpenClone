using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using OpenClone.Authorization;
using OpenClone.Core;
using OpenClone.Core.Extensions;
using OpenClone.Core.Models;
using OpenClone.Core.Models;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services.OpenAI;
using OpenClone.Services.Services;
using OpenClone.UI.Configuration;

namespace OpenClone.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger _logger;
        private readonly UserManager<ApplicationUser> _userManager;
        public IAuthorizationService _authorizationService;
        public string IsAutho = "Nope";

        public IndexModel(ILoggerFactory loggerFactory, UserManager<ApplicationUser> userManager, IAuthorizationService authorizationService, ApplicationDbContext applicationDbContext, GenerativeImageService generativeImageService, ElevenLabsService elevenLabsService, EmbeddingService<Answer> embeddingsService, CompletionService completionService)
        {
            _logger = loggerFactory.CreateLogger(GlobalVariables.OpenCloneCategory);
            _userManager = userManager;
            _authorizationService = authorizationService;
        }

        public async Task<IActionResult>  OnGetAsync()
        {
            var authorizationOperation = await _authorizationService.AuthorizeAsync(
                    User,
                    new ClaimAndPolicyQuestionExampleToBeDeleted() { Owner = "seanmchugh.info@gmail.com" },
                    AuthorizationOperations.Delete
                    );
            if(authorizationOperation.Succeeded)
            {
                IsAutho = "Yes, you are authorized";
            }
            return Page();
        }
    }
}