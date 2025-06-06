using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class Answer: Embedding
    {
        public int QuestionId { get; set; }
        [JsonIgnore]
        virtual public Question Question { get; set; }
        public int CloneId { get; set; }
        [JsonIgnore]
        virtual public Clone Clone { get; set; }
        public DateTime AnswerDate { get; set; }
    }
}
