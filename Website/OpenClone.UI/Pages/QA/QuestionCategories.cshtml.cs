using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.UI.Extensions;

namespace OpenClone.Pages
{
    [Authorize]
    [Authorize(Policy="HasActiveClone")]
    public class QAModel : PageModel
    {
        public QAService _qaService;

        public List<QuestionCategory> QuestionCategories { get; set; }

        public QAModel(QAService qAService)
        {
            _qaService = qAService;
        }

        public void OnGet()
        {
            QuestionCategories = _qaService.GetQuestionCategories();
        }
    }
}
