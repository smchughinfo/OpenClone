using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Diagnostics;

namespace OpenClone.Pages
{
    [Route("NotFound")]
    public class NotFoundModel : PageModel
    {
        public NotFoundModel()
        {
            // todo: add logging? 
        }

        public void OnGet()
        {
        }
    }
}