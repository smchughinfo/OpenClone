using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class Question : Embedding
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public int QuestionCategoryId { get; set; }
        virtual public Clone? clone { get; set; }
        public int? CloneId { get; set; }
        virtual public QuestionCategory QuestionCategory { get; set; }
        public int? GenerativeImageId { get; set; }
        virtual public GenerativeImage? GenerativeImage { get; set; }
        public string? StarterIdea1 { get; set; }
        public string? StarterIdea2 { get; set; }
        public string? StarterIdea3 { get; set; }
    }
}
