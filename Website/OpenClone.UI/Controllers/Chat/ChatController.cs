using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using OpenClone.Services.Services;
using OpenClone.Services.Services.Chat;
using OpenClone.UI.Extensions;

namespace OpenClone.UI.Controllers.Chat
{
    [Route("api/[controller]")]

    public class ChatController : _OpenCloneAPIController
    {
        CloneCRUDService _cloneCRUDService;
        ChatService _chatService;

        public ChatController(CloneCRUDService cloneCRUDService, ChatService chatService)
        {
            _cloneCRUDService = cloneCRUDService;
            _chatService = chatService;
        }

        [HttpGet("GetDefaultSystemMessage")]
        public async Task<IActionResult> GetDefaultSystemMessage()
        {
            var systemMessage = await _chatService.GetDefaultSystemMessage(_activeCloneId);
            return Ok(systemMessage);
        }

        [HttpPost("UpdateSystemMessage")]
        public async Task<IActionResult> UpdateSystemMessage([FromBody] string? systemMessage)
        {
            systemMessage = RemoveLTGT(systemMessage);
            await _cloneCRUDService.UpdateClone(User.GetActiveCloneId(), updateClone =>
            {
                updateClone.SystemMessage = systemMessage;
            });
            return Ok();
        }

        [HttpGet("GetSystemMessageData")]
        public async Task<IActionResult> GetSystemMessageData()
        {
            var systemMessageData = await _chatService.GetSystemMessageData(User.GetActiveCloneId());
            return Ok(systemMessageData);
        }
    }
}
