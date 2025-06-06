using Azure;
using Microsoft.Extensions.Configuration;
using NAudio.Wave;
using OpenClone;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services.ElevenLabs.DTOs;
using OpenClone.Services.Services;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services.ElevenLabs.DTOs;
using OpenClone.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using OpenClone.Services.Services.ElevenLabs.DTOs.VoiceListDTOs;
using Microsoft.Extensions.Logging;
using OpenClone.Core;

namespace OpenClone.Services.Services.ElevenLabs
{
    public class ElevenLabsService
    {
        // todo:  private readonly is superflous here to be honest. and really everywhere. private by default and your services dont have any public properties that can be modified. chatgpt disagrees. but i disagree with chatgpt on this one...
        private readonly string _baseUrl = "https://api.elevenlabs.io/v1";

        private readonly CloneMetadataService _cloneMetadataService;
        private readonly ConfigurationService _configurationService;
        private readonly NetworkService _networkService;
        private readonly AudioService _audioService;
        private readonly ILogger _logger;

        public ElevenLabsService(CloneMetadataService cloneMetadataService, ConfigurationService configurationService, NetworkService networkService, AudioService audioService, ILoggerFactory loggerFactory)
        {
            _cloneMetadataService = cloneMetadataService;
            _configurationService = configurationService;
            _networkService = networkService;
            _audioService = audioService;
            _logger = loggerFactory.CreateLogger(GlobalVariables.OpenCloneCategory);
        }

        public async Task<List<VoiceData>> GetVoiceList()
        {
            var url = $"{_baseUrl}/voices";
            var voiceList = await _networkService.Get<VoiceList>(url, CustomHeaders.APIKeyElevenLabs | CustomHeaders.ExpectJson);
            return voiceList.Voices;
        }

        public async Task<string> GetSpokenText(int cloneId, string textToSpeak)
        {
            var spokenTextPath = _cloneMetadataService.GetTextToSpeakPath(cloneId);
            var voiceId = await _cloneMetadataService.GetVoiceId(cloneId);
            var url = $"{_baseUrl}/text-to-speech/{voiceId}";

            var json = new
            {
                text = textToSpeak,
                model_id = "eleven_multilingual_v2",
                voice_settings = new
                {
                    stability = .5,
                    similarity_boost = .9,
                    style = .5,
                    use_speaker_boost = true // todo: does this work? was True in python. same effect?
                }
            };

            // get spoken text from ElevenLabs
            var response = await _networkService.Post<byte[]>(url, json, CustomHeaders.APIKeyElevenLabs);

            // save spoken text to file
            System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(spokenTextPath));
            File.WriteAllBytes(spokenTextPath, response);
            await _audioService.ConvertMp3ToWav(response, spokenTextPath);

            return spokenTextPath;
        }

        public async Task<string> SetVoice(int cloneId, bool log = false)
        {
            var curVoiceId = await _cloneMetadataService.GetVoiceId(cloneId);
            if(curVoiceId != null)
            {
                await DeleteVoice(curVoiceId, log);
            }
            return await AddVoice(cloneId, log);
        }

        public async Task DeleteVoice(string voiceId, bool log = false)
        {
            if (log) _logger.LogInformation($"deleting voiceId {voiceId}");

            var url = $"{_baseUrl}/voices/{voiceId}";
            await _networkService.Delete(url, CustomHeaders.APIKeyElevenLabs);
        }

        private async Task<string> AddVoice(int cloneId, bool log = false)
        {
            if (log) _logger.LogInformation($"adding voice for clone {cloneId}");

            var url = $"{_baseUrl}/voices/add";

            var audioSamplePath = _cloneMetadataService.GetCloneAudioSample(cloneId);
            using (var audioFileStream = File.OpenRead(audioSamplePath))
            {
                var data = new
                {
                    name = $"clone-{cloneId}",
                    files = audioFileStream,
                };

                var response = await _networkService.Post<VoiceId>(url, data, CustomHeaders.APIKeyElevenLabs | CustomHeaders.ExpectJson);
                return response.Id;
            }
        }

        public async Task DeleteUnusedVoices()
        {
            var elevenLabsVoiceIds = (await GetVoiceList())
                .Where(v => v.Category != "premade") // TODO: anything else (it errors when you try to delete these)?
                .Select(v => v.VoiceId)
                .ToList();
            var dbVoiceIds = await _cloneMetadataService.GetAllVoiceIds();

            var unusedVoiceIds = elevenLabsVoiceIds.Where(eId => !dbVoiceIds.Contains(eId)).ToList();
            foreach(var unusedVoiceId in unusedVoiceIds) {
                await DeleteVoice(unusedVoiceId, true);
            }
        }
    }
}
