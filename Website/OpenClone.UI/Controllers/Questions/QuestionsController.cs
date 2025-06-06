using Microsoft.AspNetCore.Mvc;
using OpenClone;
using OpenClone.Core;
using OpenClone.Core.DTOs;
using OpenClone.Core.Models;
using OpenClone.Services.Services;
using OpenClone.UI;
using OpenClone.UI.Controllers;
using OpenClone.UI.Controllers.Questions;
using OpenClone.UI.Extensions;
using System.Text.Json;

// TODO: make sure only authorized users can call this
namespace OpenClone.UI.Controllers.Questions
{
    [Route("api/[controller]")]
    public class QuestionsController : _OpenCloneAPIController
    {
        private QAService _qaService { get; set; }
        public QuestionsController(QAService qaService)
        {
            _qaService = qaService;
        }

        [HttpGet("GetQuestionsWithAnswerStatusInCategory/{categoryName}")]
        public async Task<ActionResult> GetQuestionsWithAnswerStatusInCategory(string categoryName)
        {
            var questions = new List<QuestionWithAnswer_DTO>();
            if (categoryName == "round-robin") {
                questions = await _qaService.GetAllQuestionsWithAnswerStatus(_activeCloneId);
                questions = _qaService.OrderByRoundRobin(questions);
            }
            else {
                questions = await _qaService.GetQuestionsWithAnswerStatusInCategory(_activeCloneId, categoryName);
            }
            
            return Ok(questions);
        }

        [HttpGet("GetSimiliarQuestionsWithAnswerStatus/{questionId}")]
        public async Task<ActionResult> GetSimiliarQuestionsWithAnswerStatus(int questionId)
        {
            var questions = await _qaService.GetSimiliarQuestionsWithAnswerStatus(_activeCloneId, questionId);
            return Ok(questions);
        }

        [HttpGet("GetImages/{questionId}")]
        public async Task<ActionResult> GetImages(int questionId)
        {
            var relatedImages = await _qaService.GetQuestionImages(_activeCloneId, questionId);
            return Ok(relatedImages);
        }
    }
}
