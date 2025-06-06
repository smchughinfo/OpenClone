using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using OpenClone;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.Services.Services.Chat;
using OpenClone.UI;
using OpenClone.UI.Extensions;
using OpenClone.UI.Hubs;
using System.Text.Json;

namespace OpenClone.UI.Hubs
{
    public class ChatHub : _OpenCloneHub
    {
        private readonly ChatService _chatService;
        private readonly DeepFakeOrchestrationService _deepFakeOrchestrationService;
        private readonly ApplicationUserService _applicationUserService;
        public ChatHub(
            DeepFakeOrchestrationService deepFakeOrchestrationService,
            ApplicationUserService applicationUserService,
            ChatService chatService
            ) : base (applicationUserService)
        {
            _deepFakeOrchestrationService = deepFakeOrchestrationService;
            _applicationUserService = applicationUserService;
            _chatService = chatService;
        }

        [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
        public async Task<int> GetChatSessionId()
        {
            return await _chatService.GetChatSessionId(_activeCloneId);
        }

        [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
        public async Task MessageCloneAndWaitForResponse(int chatSessionId, string message)
        {
            if(string.IsNullOrEmpty(message)) {
                return;
            }
            var chatSession = await _chatService.GetChatSession(chatSessionId);
            await _deepFakeOrchestrationService.GenerateDeepFake(chatSession, message);
        }
    }
}
