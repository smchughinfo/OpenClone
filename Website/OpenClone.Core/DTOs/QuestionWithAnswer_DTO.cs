using OpenClone;
using OpenClone.Core;
using OpenClone.Core.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.DTOs
{
    public class QuestionWithAnswer_DTO
    {
        public QuestionWithAnswer_DTO(Question question, Answer answer)
        {
            QuestionId = question.Id;
            CategoryName = question.QuestionCategory.Name;
            CategoryName_URLFriendly = question.QuestionCategory.NameToUrlFriendly();
            QuestionText = question.Text;
            AnswerText = answer == null ? null : answer.Text;
            AnswerDate = answer == null ? null : answer.AnswerDate;
            StarterIdeas = new List<string> { question.StarterIdea1, question.StarterIdea2, question.StarterIdea3 };
        }

        public int QuestionId { get; set; }
        public string CategoryName { get; set; }
        public string CategoryName_URLFriendly { get; set; }
        public string QuestionText { get; set; }
        public string? AnswerText { get; set; }
        public DateTime? AnswerDate { get; set; }
        public List<string> StarterIdeas { get; set; }
    }
}
