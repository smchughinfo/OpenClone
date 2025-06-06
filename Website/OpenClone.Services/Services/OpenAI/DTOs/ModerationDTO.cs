using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI.DTOs
{
    public class ModerationDTO
    {
        public string Id { get; set; }
        public string Model { get; set; }
        public List<ModerationResult> Results { get; set; }
    }

    public class ModerationResult
    {
        public bool Flagged { get; set; }
        public ModerationCategories Categories { get; set; }
        public ModerationCategoryScores CategoryScores { get; set; }
    }

    public class ModerationCategories
    {
        public bool Sexual { get; set; }
        public bool Hate { get; set; }
        public bool Harassment { get; set; }
        public bool SelfHarm { get; set; }
        public bool SexualMinors { get; set; }
        public bool HateThreatening { get; set; }
        public bool ViolenceGraphic { get; set; }
        public bool SelfHarmIntent { get; set; }
        public bool SelfHarmInstructions { get; set; }
        public bool HarassmentThreatening { get; set; }
        public bool Violence { get; set; }
    }

    public class ModerationCategoryScores
    {
        public float Sexual { get; set; }
        public float Hate { get; set; }
        public float Harassment { get; set; }
        public float SelfHarm { get; set; }
        public float SexualMinors { get; set; }
        public float HateThreatening { get; set; }
        public float ViolenceGraphic { get; set; }
        public float SelfHarmIntent { get; set; }
        public float SelfHarmInstructions { get; set; }
        public float HarassmentThreatening { get; set; }
        public float Violence { get; set; }
    }
}
