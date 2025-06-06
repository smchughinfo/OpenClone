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
    public class VoiceData
    {
        [JsonPropertyName("voice_id")]
        public string VoiceId { get; set; }

        [JsonPropertyName("name")]
        public string Name { get; set; }

        [JsonPropertyName("samples")]
        public object[] Samples { get; set; } // Assuming it's an array of objects

        [JsonPropertyName("category")]
        public string Category { get; set; }

        [JsonPropertyName("fine_tuning")]
        public FineTuning FineTuning { get; set; }

        [JsonPropertyName("labels")]
        public Labels Labels { get; set; }

        [JsonPropertyName("description")]
        public string Description { get; set; }

        [JsonPropertyName("preview_url")]
        public string PreviewUrl { get; set; }

        [JsonPropertyName("available_for_tiers")]
        public string[] AvailableForTiers { get; set; } // Assuming it's an array of strings

        [JsonPropertyName("settings")]
        public object Settings { get; set; } // Replace 'object' with the appropriate type if known

        [JsonPropertyName("sharing")]
        public object Sharing { get; set; } // Replace 'object' with the appropriate type if known

        [JsonPropertyName("high_quality_base_model_ids")]
        public string[] HighQualityBaseModelIds { get; set; } // Assuming it's an array of strings
    }
}
