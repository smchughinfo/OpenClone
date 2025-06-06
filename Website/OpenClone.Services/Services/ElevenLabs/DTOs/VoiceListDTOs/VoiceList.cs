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
using OpenClone.Services.Services.ElevenLabs.DTOs;

namespace OpenClone.Services.Services.ElevenLabs.DTOs.VoiceListDTOs
{
    public class VoiceList
    {
        [JsonPropertyName("voices")]
        public List<VoiceData> Voices { get; set; }
    }
}
