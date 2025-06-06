using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace OpenClone.UI.Pages.QA
{
    [Authorize]
    public class EditModel : PageModel
    {
        public void OnGet()
        {
        }
    }
}
