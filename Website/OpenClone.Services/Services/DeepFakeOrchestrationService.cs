using Microsoft.Extensions.DependencyInjection;
using OpenClone.Core.Models.Enums;
using OpenClone.Core.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using OpenClone.Core;
using OpenClone.Services.Services.Chat;
using OpenClone.Services.Services.ElevenLabs;

namespace OpenClone.Services.Services
{
    public class DeepFakeOrchestrationService
    {
        private readonly CloneMetadataService _cloneMetadataService;
        private readonly ChatService _chatService;
        private readonly RenderingService _renderingService;
        private readonly ElevenLabsService _elevenLabsService;
        public DeepFakeOrchestrationService(CloneMetadataService cloneMetadataService, ChatService chatService, RenderingService renderingService, ElevenLabsService elevenLabsService) { 
            _cloneMetadataService = cloneMetadataService;
            _chatService = chatService;
            _renderingService = renderingService;
            _elevenLabsService = elevenLabsService;
        }

        public async Task GenerateDeepFake(ChatSession chatSession, string messageToClone)
        {
            var chatCompletion = await _chatService.SendMessage(chatSession, messageToClone);
            await _elevenLabsService.GetSpokenText(chatSession.CloneId, chatCompletion);

            var deepFakeMode = await _cloneMetadataService.GetDeepFakeMode(chatSession.CloneId);
            if (deepFakeMode == DeepFakeMode.DeepFake)
            {
                GenerateDeepFake(chatSession.CloneId);
                await WaitOnM3U8(chatSession.CloneId);
            }
        }

        void GenerateDeepFake(int cloneId)
        {
            var sourceImagePath = _cloneMetadataService.GetCloneImageNoBG(cloneId);
            var textToSpeakPath = _cloneMetadataService.GetTextToSpeakPath(cloneId);
            var m3u8Path = _cloneMetadataService.GetM3U8Path(cloneId);
            _renderingService.GenerateDeepFakeStream(sourceImagePath, textToSpeakPath, m3u8Path);
        }

        private async Task WaitOnM3U8(int cloneId, int timeoutMilliseconds = int.MaxValue)
        {
            var m3u8Path = _cloneMetadataService.GetM3U8Path(cloneId);
            var startTime = DateTime.Now;
            while (DateTime.Now.Subtract(startTime).TotalMilliseconds < timeoutMilliseconds)
            {
                if (File.Exists(m3u8Path))
                {
                    return;
                }
                await Task.Delay(100);
            }
            throw new OpenCloneException(OpenCloneException.DEEPFAKE_FAILED, true);
        }
    }
}
