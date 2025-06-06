using Microsoft.AspNetCore.Mvc;
using OpenClone.Core.Models;
using OpenClone.Services.Services;
using OpenClone.UI.Extensions;
using System.Text.Json;

// TODO: make sure only authorized users can call this
using Microsoft.AspNetCore.Mvc;
using OpenClone.Services.Services;
using OpenClone.UI.Extensions;
using OpenClone;
using OpenClone.UI;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.Answers;
using OpenClone.UI.Controllers.Answers.DTOs;
using OpenClone.Services.Services.OpenAI;

namespace OpenClone.UI.Controllers.Answers
{
    [Route("api/[controller]")]
    public class AnswersController : _OpenCloneAPIController
    {
        private QAService _qaService { get; set; }
        public AnswersController(QAService qaService)
        {
            _qaService = qaService;
        }

        [HttpGet("GetAllAnswers")]
        public async Task<ActionResult> GetAllAnswers()
        {
            var answers = await _qaService.GetAllQuestionsWithAnswers(_activeCloneId);
            return Ok(answers);
        }

        [HttpPost("SaveAnswer")]
        public async Task<ActionResult> SaveAnswer([FromBody] Answer_DTO answer)
        {
            await _qaService.CreateOrUpdateAnswer(_activeCloneId, answer.QuestionId, answer.AnswerText);
            return Ok();
        }

        [HttpPost("DeleteAnswer")]
        public async Task<ActionResult> DeleteAnswer([FromBody] int answerId)
        {
            await _qaService.DeleteAnswer(_activeCloneId, answerId);
            return Ok();
        }

        [HttpPost("SaveCustomQA")]
        public async Task<ActionResult> SaveCustomQA([FromBody] CustomQA_DTO customQA)
        {
            await _qaService.CreateCustomQA(_activeCloneId, customQA.QuestionText, customQA.AnswerText);
            return Ok();
        }
    }
}