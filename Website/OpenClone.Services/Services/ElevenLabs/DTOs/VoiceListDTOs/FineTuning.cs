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
    public class FineTuning
    {
        [JsonPropertyName("language")]
        public string Language { get; set; }

        [JsonPropertyName("is_allowed_to_fine_tune")]
        public bool IsAllowedToFineTune { get; set; }

        [JsonPropertyName("fine_tuning_requested")]
        public bool FineTuningRequested { get; set; }

        [JsonPropertyName("finetuning_state")]
        public string FinetuningState { get; set; }

        [JsonPropertyName("verification_attempts")]
        public object VerificationAttempts { get; set; } // Replace 'object' with the appropriate type if known

        [JsonPropertyName("verification_failures")]
        public object[] VerificationFailures { get; set; } // Assuming it's an array of objects

        [JsonPropertyName("verification_attempts_count")]
        public int VerificationAttemptsCount { get; set; }

        [JsonPropertyName("slice_ids")]
        public object SliceIds { get; set; } // Replace 'object' with the appropriate type if known

        [JsonPropertyName("manual_verification")]
        public object ManualVerification { get; set; } // Replace 'object' with the appropriate type if known

        [JsonPropertyName("manual_verification_requested")]
        public bool ManualVerificationRequested { get; set; }
    }
}
