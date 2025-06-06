using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services.OpenAI;
using OpenClone.Services.Services;
using OpenClone.UI;
using OpenClone.UI.Extensions;
using System.Text;
using System.Text.Json;

namespace OpenClone.Pages
{
    [IgnoreAntiforgeryToken] // todo: do these antiforgery shits
    public class ChatBotModel : PageModel
    {
        public ChatBotModel() { }
    }
}
