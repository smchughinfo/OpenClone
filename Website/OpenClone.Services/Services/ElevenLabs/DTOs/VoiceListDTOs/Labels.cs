using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using OpenClone;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services.ElevenLabs.DTOs;

namespace OpenClone.Services.Services.ElevenLabs.DTOs.VoiceListDTOs
{
    public class Labels
    {
        [JsonPropertyName("accent")]
        public string Accent { get; set; }

        [JsonPropertyName("description")]
        public string Description { get; set; }

        [JsonPropertyName("age")]
        public string Age { get; set; }

        [JsonPropertyName("gender")]
        public string Gender { get; set; }

        [JsonPropertyName("use case")]
        public string UseCase { get; set; }
    }
}
