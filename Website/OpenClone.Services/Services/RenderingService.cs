using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using OpenClone;
using OpenClone.Services;
using OpenClone.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Web;
using static System.Net.Mime.MediaTypeNames;
using OpenClone.Core;
using OpenClone.Services.Services;
using System.Threading.Tasks.Dataflow;

namespace OpenClone.Services.Services
{
    public class RenderingService
    {
        ConfigurationService _configurationService;
        CloneMetadataService _cloneMetadataService;
        NetworkService _networkService;
        public RenderingService(ConfigurationService configurationService, CloneMetadataService cloneMetadataService, NetworkService networkService)
        {
            _configurationService = configurationService;
            _cloneMetadataService = cloneMetadataService;
            _networkService = networkService;
        }


        /*
         important todo:
        batch jobs need to be registered in database to avoid duplicate runs conflicting with each other and causing weird errors
        also prevents user from pressing the run button 100 times and dds'ing the server
         */



        /// <param name="tsSegmentLength">"Buffer" size of video stream, in seconds</param>
        /// <returns></returns>
        public async Task GenerateDeepFakeStream(string sourceImagePath, string sourceAudioPath, string m3u8Path, int tsSegmentLength = 5)
        {
            Func<Task> _generateDeepfakeStream = async () => {
                CleanupOldStreamFiles(m3u8Path);

                var url = $"{_configurationService.GetSadTalkerHostAddress()}/generate-deepfake";
                var data = new
                {
                    imagePath = ConvertToRelativePath(sourceImagePath),
                    audioPath = ConvertToRelativePath(sourceAudioPath),
                    m3u8Path = ConvertToRelativePath(m3u8Path),
                    tsSegmentLength = 10
                };
                await _networkService.Post(url, data, CustomHeaders.ExpectJson);
            };

            try
            {
                await _generateDeepfakeStream();
            }
            catch (Exception ex)
            {
                // todo: does it ever get here?
                await _generateDeepfakeStream();
            }
        }

        private void CleanupOldStreamFiles(string m3u8Path)
        {
            var m3u8Dir = Path.GetDirectoryName(m3u8Path);
            if(Directory.Exists(m3u8Dir)) Directory.Delete(m3u8Dir, true);
        }

        public async Task GenerateDeepFakeMp4(string sourceImagePath, string sourceAudioPath, string mp4Path, bool removeAudio = true)
        {
            var url = $"{_configurationService.GetSadTalkerHostAddress()}/generate-deepfake";
            var data = new
            {
                imagePath = ConvertToRelativePath(sourceImagePath),
                audioPath = ConvertToRelativePath(sourceAudioPath),
                mp4Path = ConvertToRelativePath(mp4Path),
                removeAudioFromMp4 = removeAudio
            };
            await _networkService.Post(url, data, CustomHeaders.ExpectJson);
        }

        /// <param name="threshold">0-255 how aggressive to be when applying background removal mask.</param>
        public async Task RemoveBackgroundImage(string sourceImagePath, string outputImagePath, int threshold=200)
        {
            var url = $"{_configurationService.GetU2NetHostName()}/remove-background";
            var data = new
            {
                sourceImagePath = ConvertToRelativePath(sourceImagePath),
                outputImagePath = ConvertToRelativePath(outputImagePath),
                threshold = threshold
            };
            await _networkService.Post(url , data, CustomHeaders.ExpectJson);
        }

        private string ConvertToRelativePath(string filePath)
        {
            // Replace the file's local path with the corresponding path inside the SadTalker/U-2-Net Docker volume.
            filePath = filePath.Replace(_configurationService.GetOpenCloneFSPath(), "");

            // Convert Windows backslashes to forward slashes for compatibility with the Linux-based SadTalker container.
            filePath = filePath.Replace("\\", "/");

            return filePath;
        }
    }
}
