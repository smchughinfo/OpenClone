using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using OpenClone;
using OpenClone.Core;
using OpenClone.Core.Attributes;
using OpenClone.Core.Extensions;
using OpenClone.Core.Models;
using OpenClone.Core.Models.Enums;
using OpenClone.Services;
using OpenClone.Services.Extensions;
using OpenClone.Services.Services;
using OpenClone.Services.Services.Chat;
using OpenClone.Services.Services.Chat.DTOs;
using OpenClone.Services.Services.OpenAI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.Chat
{
    public partial class ChatService
    {
        ApplicationDbContext _applicationDbContext;
        CloneCRUDService _cloneCRUDService;
        IMapper _mapper;
        QAService _qAService;
        CompletionService _completionService;

        public ChatService(ApplicationDbContext applicationDbContext, CloneCRUDService cloneCRUDService, IMapper mapper, QAService qAService, CompletionService completionService)
        {
            _cloneCRUDService = cloneCRUDService;
            _applicationDbContext = applicationDbContext;
            _mapper = mapper;
            _qAService = qAService;
            _completionService = completionService;
        }

        public async Task<string> GetDefaultSystemMessage(int cloneId)
        {
            var systemMessage = DEFAULT_SYSTEM_MESSSAGE_TEMPLATE;
            var identityMessageData = (await GetSystemMessageData(cloneId)).Where(d => d.Category == IDENTITY_CATEGORY);

            var identityString = "";
            foreach (var data in identityMessageData)
            {
                if (!string.IsNullOrEmpty(data.Value))
                {
                    var replacementString = $"{data.Key.ConvertCamelCaseToSpaces()}: {{{data.Key}}}, ";
                    identityString += replacementString;
                }
            }
            identityString = identityString.Substring(0, identityString.Length - 2);
            systemMessage = systemMessage.Replace("{CLONE_IDENTITY}", identityString);

            return systemMessage;
        }

        public async Task<string> GetSystemMessage(int cloneId, string messageToClone)
        {
            var relatedQA = await _qAService.GetRelatedQA(cloneId, messageToClone);
            var systemMessage = (await _cloneCRUDService.GetCloneAsync(cloneId)).SystemMessage;
            if (systemMessage == null) {
                systemMessage = await GetDefaultSystemMessage(cloneId);
            }
            var qaList = relatedQA.Select(c => $"Question: {c.Key}; Answer {c.Value}").ToList();
            return systemMessage.Replace("{AnsweredQuestions}", string.Join("\n", qaList));
        }

        public async Task<int> GetChatSessionId(int cloneId)
        {
            var chatSession = await _applicationDbContext.ChatSession.SingleOrDefaultAsync(s => s.CloneId == cloneId);
            if (chatSession == null)
            {
                chatSession = new ChatSession() { CloneId = cloneId };
                await _applicationDbContext.ChatSession.AddAsync(chatSession);
                await _applicationDbContext.SaveChangesAsync();
            }
            return chatSession.Id;
        }

        public async Task<ChatSession> GetChatSession(int sessionId)
        {
            return await _applicationDbContext.ChatSession.SingleAsync(s => s.Id == sessionId);
        }

        public async Task<List<SystemMessageData_DTO>> GetSystemMessageData(int cloneId)
        {
            var systemMessageData = new List<SystemMessageData_DTO>();

            var activeClone = await _cloneCRUDService.GetCloneAsync(cloneId);
            activeClone.IterateOverProperties<SystemMessageDataAttribute>((key, value, isDefaultValue) =>
            {
                systemMessageData.Add(new SystemMessageData_DTO()
                {
                    Category = IDENTITY_CATEGORY,
                    Key = key,
                    Value = value == null ? null : value.ToString(),
                    Populated = !isDefaultValue
                });
            });

            var answerCount = await _qAService.AnswerCount(cloneId);
            systemMessageData.Add(new SystemMessageData_DTO()
            {
                Category = QA_CATEGORY,
                Key = "AnsweredQuestions",
                Value = answerCount.ToString(),
                Populated = answerCount > 0
            });

            return systemMessageData;
        }

        public async Task<string> SendMessage(ChatSession chatSession, string messageToClone)
        {
            var systemMessage = await GetSystemMessage(chatSession.CloneId, messageToClone);
            chatSession.ChatMessages.Add(new ChatMessage()
            {
                Message = messageToClone, 
                ChatRoleLookupId = (int)ChatRole.User,
                TimeStamp = DateTime.UtcNow,
                ChatSessionId = chatSession.Id
            });
            var chatCompletion = await _completionService.GetChatCompletion(systemMessage, chatSession);
            chatSession.ChatMessages.Add(new ChatMessage()
            {
                Message = chatCompletion,
                ChatRoleLookupId = (int)ChatRole.Assistant,
                TimeStamp = DateTime.UtcNow,
                ChatSessionId = chatSession.Id
            });
            _applicationDbContext.SaveChanges();

            return chatCompletion;
        }
    }
}
