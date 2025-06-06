using OpenClone.UI.Attributes;
using System.ComponentModel.DataAnnotations;

namespace OpenClone.UI.Controllers.Answers.DTOs
{
    public class Answer_DTO
    {
        [Required]
        public int QuestionId { get; set; }
        [Required]
        [NoWhitespaceOnly]
        public string? AnswerText { get; set; }
    }
}
