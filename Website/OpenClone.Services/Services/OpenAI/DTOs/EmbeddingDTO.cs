using OpenClone.Core.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI.DTOs
{
    internal class EmbeddingDTO
    {
        public string Object { get; set; }
        public List<EmbeddingData> Data { get; set; }
        public string Model { get; set; }
        public Usage Usage { get; set; }
    }

    internal class EmbeddingData
    {
        public string Object { get; set; }
        public int Index { get; set; }
        public List<float> Embedding { get; set; }
    }
}
