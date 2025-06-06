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

namespace OpenClone.Services.Services.ElevenLabs.DTOs
{
    public class VoiceId
    {
        [JsonPropertyName("voice_id")]
        public string Id { get; set; }
    }
}
