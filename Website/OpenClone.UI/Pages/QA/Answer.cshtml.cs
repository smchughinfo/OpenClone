using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.UI.Extensions;

namespace OpenCloneUI.Pages.QA
{
    [IgnoreAntiforgeryToken] // todo: what's this?
    [Authorize]
    public class AnswerModel : PageModel
    {
        ApplicationDbContext _applicationDbContext;
        public QAService _qaService { get; set; }
        public ApplicationUserService _applicationUserService { get; set; }
        public QuestionCategory QuestionCategory { get; set; }
        public List<Answer> CloneAnswers { get; set; }
        public List<Question> Questions { get; set; }

        public AnswerModel(ApplicationDbContext applicationDbContext, QAService qaService, ApplicationUserService applicationUserService)
        {
            _applicationDbContext = applicationDbContext;
            _qaService = qaService;
            _applicationUserService = applicationUserService;
        }

        //[Route("/QA/Answer/{categoryName}")]
        public void OnGet()
        {
            // TODO: this method could be more async
            var activeCloneId = _applicationUserService.GetActiveCloneId(User.GetId()).Value;

            var categoryName = HttpContext.Request.Path.ToString().Split('/')[3]; // this should be reliable. invalid categories are 404'd via PagesAndControllersConfigurator
            categoryName = QuestionCategory.UrlFriendlyToName(categoryName);

            if(categoryName == "round robin")
            {
                Questions = _qaService.GetAllSystemQuestions();
                CloneAnswers = _qaService.GetAllAnswers(activeCloneId);
            }
            else
            {
                QuestionCategory = _applicationDbContext.QuestionCategory.Single(c => c.Name == categoryName);
                Questions = QuestionCategory.Questions.ToList().Take(1).ToList();
                CloneAnswers = _qaService.GetAnswersForQuestionCategory(activeCloneId, QuestionCategory.Id);
            }
        }

        public IActionResult OnPostSaveAnswer([FromBody] QuestionDTO questionDTO)
        {
            //_qaService.CreateOrUpdateAnswer(User.GetId(), questionDTO.QuestionId, questionDTO.Answer);
            return new OkResult();
        }
    }

    public class QuestionDTO
    {
        public string Answer { get; set; }
        public int QuestionId { get; set; }
    }
}
