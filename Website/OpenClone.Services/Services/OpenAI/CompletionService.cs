    using Azure.Identity;
using Microsoft.Extensions.Configuration;
using OpenClone;
using OpenClone.Core;
using OpenClone.Core.Extensions;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.Services.Services.OpenAI;
using OpenClone.Services.Services.OpenAI.DTOs;
using OpenClone.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;
using OpenClone.Core.Models.Enums;
using NAudio.CoreAudioApi;

namespace OpenClone.Services.Services.OpenAI
{
    public class CompletionService
    {
        private readonly ConfigurationService _configurationService;
        private readonly NetworkService _networkService;

        private readonly string _baseUrl = "https://api.openai.com/v1/chat";

        public CompletionService(ConfigurationService configurationService, EmbeddingService<Answer> embeddingsService, NetworkService networkService)
        {
            _configurationService = configurationService;
            _networkService = networkService;
        }

        public async Task<string> GetChatCompletion(string systemMessage, ChatSession chatSession)
        {
            var url = $"{_baseUrl}/completions";

            var messages = chatSession.ChatMessages.Select(m =>
                new
                {
                    role = Enum.GetName(typeof(ChatRole), m.ChatRoleLookupId).ToLower(),
                    content = m.Message
                }
            ).ToList();
            messages = messages.Prepend(new { role = "system", content = systemMessage }).ToList();
            
            var data = new {
                //model = "gpt-3.5-turbo",
                model = "gpt-4",
                messages = messages
            };

            var completion = await _networkService.Post<CompletionDTO>(url, data, CustomHeaders.APIKeyOpenAI | CustomHeaders.ExpectJson);
            return completion.Choices[0].Message.Content;
        }

        public async Task<string> GetChatCompletion(string systemMessage, string message)
        {
            var url = $"{_baseUrl}/completions";
            var data = new
            {
                //model = "gpt-3.5-turbo",
                model = "gpt-4",
                messages = new[] {
                        new { role = "system", content = systemMessage },
                        new { role = "user", content = message }
                }
            };

            var completion = await _networkService.Post<CompletionDTO>(url, data, CustomHeaders.APIKeyOpenAI | CustomHeaders.ExpectJson);
            return completion.Choices[0].Message.Content;
        }
    }
}
