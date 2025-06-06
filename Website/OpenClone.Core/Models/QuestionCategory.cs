using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class QuestionCategory
    {
        [Key]
        public int Id { get; set; }
        [Required] // TODO: index this
        public string Name { get; set; }
        [Required]
        virtual public IEnumerable<Question> Questions { get; set; }

        //TODO: is there a better place for this?
        public string NameToUrlFriendly()
        {
            var name = Name.Replace("-", "--");
            name = name.Replace(" ", "-");
            return name;
        }
        public static string UrlFriendlyToName(string queryString)
        {
            var name = queryString.Replace("-", " ");
            name = name.Replace("  ", "-");
            return name;
        }

        public object ToDTO()
        {
            return new
            {
                Id = Id,
                Name = Name,
                Questions = Questions.Select(q =>
                {
                    return new {
                        Id = q.Id,
                    };
                })
            };
        }
    }
}
