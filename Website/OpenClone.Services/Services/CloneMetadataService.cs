using AutoMapper.Configuration.Conventions;
using Castle.Core.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using OpenClone;
using OpenClone.Core.Models;
using OpenClone.Core.Models.Enums;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.Services.Services;
using OpenCvSharp.Internal.Vectors;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services
{
    public class CloneMetadataService
    {
        ApplicationDbContext _applicationDbContext;
        ApplicationUserService _applicationUserService;
        ConfigurationService _configurationService;

        public CloneMetadataService(ApplicationDbContext applicationDbContext, ConfigurationService configurationService, ApplicationUserService applicationUserService)
        {
            _applicationDbContext = applicationDbContext;
            _configurationService = configurationService;
            _applicationUserService = applicationUserService;
        }

        public async Task<string> GetVoiceId(int cloneId)
        {
            return await _applicationDbContext.Clone
                .Where(c => c.Id == cloneId)
                .Select(c => c.VoiceId)
                .SingleAsync();
        }

        public async Task<List<string>> GetAllVoiceIds()
        {
            return await _applicationDbContext.Clone
                .Select(c => c.VoiceId)
                .ToListAsync();
        }

        public string GetCloneDir(int cloneId)
        {
            var cloneDir = Path.Join(_configurationService.GetOpenCloneFSPath(), "Clones", cloneId.ToString());
            if (!Directory.Exists(cloneDir))
            {
                Directory.CreateDirectory(cloneDir);
            }
            return cloneDir;
        }

        public string GetCloneImageWithBG(int cloneId)
        {
            return Path.Combine(GetCloneDir(cloneId), "clone-image-with-bg.png");
        }

        public string GetCloneImageNoBG(int cloneId)
        {
            return Path.Combine(GetCloneDir(cloneId), "clone-image-no-bg.png");
        }

        public string GetCloneAudioSample(int cloneId)
        {
            return Path.Combine(GetCloneDir(cloneId), "audio-sample.wav");
        }

        public string GetSourceImagesDir(int cloneId)
        {
            var cloneDir = GetCloneDir(cloneId);
            var sourceImagesDir = Path.Join(cloneDir, "SourceImages");
            if (!Path.Exists(sourceImagesDir))
            {
                Directory.CreateDirectory(sourceImagesDir);
            }
            return sourceImagesDir;
        }

        public string GetDeepFakeDir(int cloneId)
        {
            return Path.Join(GetCloneDir(cloneId), "DeepFake");
        }

        public string GetQuickFakeBaseVideo(int cloneId)
        {
            return Path.Join(GetCloneDir(cloneId), "quick-fake.mp4");
        }

        public string GetStreamingDir(int cloneId)
        {
            return Path.Join(GetDeepFakeDir(cloneId), "Stream");
        }

        public void DeleteDeepFakeDir(int cloneId)
        {
            var deepfakeDirPath = GetDeepFakeDir(cloneId);
            if (Directory.Exists(deepfakeDirPath)) Directory.Delete(deepfakeDirPath, true);
        }

        public string GetTextToSpeakPath(int cloneId)
        {
            return Path.Join(GetDeepFakeDir(cloneId), "text-to-speak.wav");
        }

        public async Task SetActiveCloneToCloneWithMostRecentCreateDate(string userId)
        {
            var cloneWithMostRecentCreateDate = await _applicationDbContext.Clone
                .OrderByDescending(c => c.CreateDate)
                .FirstOrDefaultAsync();
            if (cloneWithMostRecentCreateDate != null)
            {
                await _applicationUserService.SetActiveCloneId(userId, cloneWithMostRecentCreateDate.Id);
            }
        }

        public bool CloneExists(string userId, string firstName)
        {
            return _applicationDbContext.Clone.Any(c => c.ApplicationUserId == userId && c.FirstName.ToLower() == firstName.Trim().ToLower());
        }

        public async Task<DeepFakeMode> GetDeepFakeMode(int cloneId)
        {
            return (await _applicationDbContext.Clone.FindAsync(cloneId)).DeepFakeMode.GetEnum();
        }

        public async Task SetDeepFakeMode(int cloneId, int deepFakeModeId)
        {
            var clone = await GetClone(cloneId);
            clone.DeepFakeMode = new DeepFakeModeLookup(deepFakeModeId);
            await _applicationDbContext.SaveChangesAsync();
        }

        public string GetM3U8Path(int cloneId)
        {
            return Path.Join(GetStreamingDir(cloneId), "stream.m3u8");
        }

        public string GetCloneStreamURL(int cloneId)
        {
            var openCloneFSPath = _configurationService.GetOpenCloneFSPath();
            var m3u8Path = GetM3U8Path(cloneId);
            return m3u8Path
                .Replace(openCloneFSPath, "/OpenCloneFS/")
                .Replace(@"\", "/")
                .Replace("//", "/");
        }

        private async Task<Clone> GetClone(int cloneId)
        {
            return await _applicationDbContext.Clone.FindAsync(cloneId);
        }
    }
}
