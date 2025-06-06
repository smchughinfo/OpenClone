using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using OpenClone;
using OpenClone.Core;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services.OpenAI;
using OpenClone.Services.Services;
using OpenCvSharp;
using static System.Net.Mime.MediaTypeNames;
using Image = SixLabors.ImageSharp.Image;
using SixLabors.ImageSharp;

namespace OpenClone.Services.Services
{
    public class CloneCRUDService
    {
        ApplicationDbContext _applicationDbContext;
        ApplicationUserService _applicationUserService;
        QAService _qAService;
        CompletionService _openAIService;
        EmbeddingService<Answer> _embeddingsService;
        RenderingService _renderingService;
        IMapper _mapper;
        ElevenLabsService _elevenLabsService;
        CloneMetadataService _cloneMetadataService;
        ConfigurationService _configurationService;

        public CloneCRUDService(ApplicationDbContext applicationDbContext, ApplicationUserService userService, QAService qAService, CompletionService openAIService, EmbeddingService<Answer> embeddingsService, RenderingService renderingService, IMapper mapper, ElevenLabsService elevenLabsService, CloneMetadataService cloneMetadataService, ConfigurationService configurationService)
        {
            _applicationDbContext = applicationDbContext;
            _applicationUserService = userService;
            _qAService = qAService;
            _openAIService = openAIService;
            _embeddingsService = embeddingsService;
            _renderingService = renderingService;
            _mapper = mapper;
            _elevenLabsService = elevenLabsService;
            _cloneMetadataService = cloneMetadataService;
            _configurationService = configurationService;
        }
        
        /// <param name="audioSample">Must be .wav</param>
        public async Task CreateClone(string userId, Clone clone, Image image, Stream audioSample)
        {
            var cloneExists = _cloneMetadataService.CloneExists(userId, clone.FirstName);
            if (cloneExists)
            {
                var exceptionMessage = OpenCloneException.CLONE_DUP_CHECK_FAILED.Replace("[FirstName]", clone.FirstName);
                throw new OpenCloneException(exceptionMessage, true, null, clone.AllowLogging);
            }

            using (var transaction = await _applicationDbContext.Database.BeginTransactionAsync())
            {
                try
                {
                    // save clone in db
                    clone.ApplicationUserId = userId;
                    clone.CreateDate = DateTime.UtcNow;
                    _applicationDbContext.Clone.Add(clone);
                    await _applicationDbContext.SaveChangesAsync();

                    // save clone images
                    await SetCloneImage(clone.Id, image);

                    // save clone audio sample and update voice
                    clone.VoiceId = await SetCloneAudio(clone, audioSample);
                    await _applicationDbContext.SaveChangesAsync();

                    // make the new clone the user's active clone
                    await _applicationUserService.SetActiveCloneId(userId, clone.Id);

                    // commit the transaction if everything is successful
                    await transaction.CommitAsync();
                }
                catch (Exception ex)
                {
                    // rollback the transaction if any error occurs
                    await transaction.RollbackAsync();
                    Directory.Delete(_cloneMetadataService.GetCloneDir(clone.Id), true);
                    throw new OpenCloneException(OpenCloneException.CLONE_CREATION_FAILED, true, ex, clone.AllowLogging);
                }
            }
        }

        /// <param name="image">If null nothing will change. If value provided it must be .png</param>
        /// <param name="audioSample">If null nothing will change. If value provided it must be .wav</param>
        public async Task UpdateClone(Clone clone, Image image = null, Stream audioSample = null)
        {
            if (image != null)
            {
                await SetCloneImage(clone.Id, image);
            }

            var dbClone = await _applicationDbContext.Clone.SingleAsync(c => c.Id == clone.Id);
            clone.ApplicationUserId = dbClone.ApplicationUserId;

            var voiceId = "";
            if (audioSample != null)
            {
                voiceId = await SetCloneAudio(clone, audioSample);
                clone.VoiceId = voiceId;
            }
            else
            {
                clone.VoiceId = dbClone.VoiceId;
            }

            _mapper.Map(clone, dbClone);
            await _applicationDbContext.SaveChangesAsync();
        }

        public async Task UpdateClone(int cloneId, Action<Clone> onUpdateClone)
        {
            var clone = await GetCloneAsync(cloneId);
            onUpdateClone(clone);
            await _applicationDbContext.SaveChangesAsync();
        }

        private async Task SetCloneImage(int cloneId, Image image)
        {
            // todo: sadtalker will crash if it doesnt recognize a face
            // todo: can you improve u-2 net by mirroring the image and sending it back in 
            // this function tries to be resilient to failures.

            // this one is safe to delete 
            _cloneMetadataService.DeleteDeepFakeDir(cloneId);

            // use temporary paths so if file operations fail we can revert
            var bgImagePath = _cloneMetadataService.GetCloneImageWithBG(cloneId);
            var noBgImagePath = _cloneMetadataService.GetCloneImageNoBG(cloneId);
            var mp4Path = _cloneMetadataService.GetQuickFakeBaseVideo(cloneId);
            var bgImagePathTmp = bgImagePath + ".tmp.png";
            var noBgImagePathTmp = noBgImagePath + ".tmp.png";
            var mp4PathTmp = mp4Path + ".tmp.mp4";
            var quickFakeAudioPath = _configurationService.GetQuickFakeAudio();

            try
            {
                await image.SaveAsPngAsync(bgImagePathTmp);
                await _renderingService.RemoveBackgroundImage(bgImagePathTmp, noBgImagePathTmp);
                await _renderingService.GenerateDeepFakeMp4(noBgImagePathTmp, quickFakeAudioPath, mp4PathTmp, true);

                File.Copy(bgImagePathTmp, bgImagePath, true);
                File.Copy(noBgImagePathTmp, noBgImagePath, true);
                File.Copy(mp4PathTmp, mp4Path, true);
            }
            catch (Exception ex)
            {
                throw new OpenCloneException(OpenCloneException.CLONE_UPDATE_FAILED, true, ex);
            }
            finally
            {
                File.Delete(bgImagePathTmp);
                File.Delete(noBgImagePathTmp);
                File.Delete(mp4PathTmp);
            }
        }

        private async Task<string> SetCloneAudio(Clone clone, Stream audioSample)
        {
            var audioSamplePath = _cloneMetadataService.GetCloneAudioSample(clone.Id);
            using (var fileStream = new FileStream(audioSamplePath, FileMode.Create, FileAccess.Write)) {
                await audioSample.CopyToAsync(fileStream);
            }
            return await _elevenLabsService.SetVoice(clone.Id, clone.AllowLogging);
        }

        public List<Clone> GetClones(string userId)
        {
            return _applicationDbContext.Clone.Where(c => c.ApplicationUserId == userId).ToList();
        }

        public Clone GetClone(int cloneId) // TODO: these all need to be async
        {
            return _applicationDbContext.Clone.Single(c => c.Id == cloneId);
        }

        public async Task<Clone> GetCloneAsync(int cloneId) // TODO: DELETE THIS. I JUST DONT WANT TO MAKE ALL THE CALLS TO GETCLONE ASYNC RIGHT NOW. THEY SHOULD BE ONE FUNCTION
        {
            return await _applicationDbContext.Clone.SingleAsync(c => c.Id == cloneId);
        }

        public async Task<Clone> GetActiveClone(string userId)
        {
            var activeCloneId = _applicationUserService.GetActiveCloneId(userId).Value;
            return await GetCloneAsync(activeCloneId);
        }

        public async Task DeleteClone(string userId, int cloneId)
        {
            // TODO: IMPORTANT - if it fails to delete elevenlabs voice, which is not uncommon, clone deletion will fail. 
            var logErrors = false; // if it fails before this gets set it will lead to a situation where logging is allowed but doesn't happen. but i guess that could happen anywhere since the clone has to be pulled out of the db before we know whether or not we can log. todo: should something be done about that?
            var cloneDir = _cloneMetadataService.GetCloneDir(cloneId);
            var isActiveClone = _applicationUserService.GetActiveCloneId(userId) == cloneId;

            using (var transaction = await _applicationDbContext.Database.BeginTransactionAsync())
            {
                try
                {
                    var cloneToDelete = await _applicationDbContext.Clone.SingleAsync(c => c.Id == cloneId && c.ApplicationUserId == userId);

                    // delete clone's voice from ElevenLabs
                    var voiceId = await _cloneMetadataService.GetVoiceId(cloneId);
                    await _elevenLabsService.DeleteVoice(voiceId, cloneToDelete.AllowLogging);

                    // delete from database (if clone belongs to this user)
                    logErrors = cloneToDelete.AllowLogging;
                    _applicationDbContext.Clone.Remove(cloneToDelete);
                    await _applicationDbContext.SaveChangesAsync();

                    // unset this clone as the active clone
                    if (isActiveClone)
                    {
                        await _cloneMetadataService.SetActiveCloneToCloneWithMostRecentCreateDate(userId);
                    }

                    // Commit the transaction if everything is successful
                    await transaction.CommitAsync();

                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    throw new OpenCloneException(OpenCloneException.DELETE_CLONE_FAILED, true, ex, logErrors);
                }
            }

            // todo: if you wanted to be really thorough you could add clone id to logs and delete all logs as well.
            // delete from file system
            Directory.Delete(cloneDir, true);
        }
    }
}
