using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI.DTOs
{

    public class GenerativeImageDTO
    {
        public long Created { get; set; }

        public List<GenerativeImageData> Data { get; set; }
    }

    public class GenerativeImageData
    {
        public string RevisedPrompt { get; set; }

        public string Url { get; set; }
    }
}
