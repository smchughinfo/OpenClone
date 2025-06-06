using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace OpenClone.Pages
{
    [Authorize(Policy = "HasActiveClone")]
    public class TestPageModel : PageModel
    {
        public IActionResult OnGet()
        {
            return Page();
        }
    }
}
