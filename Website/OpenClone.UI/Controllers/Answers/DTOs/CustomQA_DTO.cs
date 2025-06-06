using OpenClone.UI.Attributes;
using System.ComponentModel.DataAnnotations;

namespace OpenClone.UI.Controllers.Answers.DTOs
{
    public class CustomQA_DTO
    {
        [Required]
        [NoWhitespaceOnly]
        public string QuestionText { get; set; }
        [Required]
        [NoWhitespaceOnly]
        public string AnswerText { get; set; }
    }
}
