using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.RazorPages;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.UI.Extensions;

namespace OpenClone.Pages
{
    [IgnoreAntiforgeryToken] // todo: antiforgery token shits
    public class CloneCRUDModel : PageModel
    {
        public CloneCRUDModel() { }
    }
}
