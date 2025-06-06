using OpenClone.Services.Services.OpenAI.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI
{
    public class ModerationsService
    {
        private readonly NetworkService _networkService;
        private readonly string _baseUrl = "https://api.openai.com/v1/moderations";
        public ModerationsService(NetworkService networkService)
        {
            _networkService = networkService;
        }

        public async Task<bool> WillBeFlagged(string text)
        {
            var response = await _networkService.Post<ModerationDTO>(_baseUrl, new { input = text }, CustomHeaders.APIKeyOpenAI | CustomHeaders.ExpectJson);
            return response.Results.Any(r => r.Flagged);
        }
    }
}
