using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Primitives;
using Microsoft.Identity.Client;
using NAudio.SoundFont;
using OpenClone;
using OpenClone.Core;
using OpenClone.Core.Extensions;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.Services.Services.OpenAI;
using OpenClone.Services.Services.OpenAI.DTOs;
using OpenClone.Services.Services.OpenAI.Enums;
using OpenClone.Services.Services.OpenAI.Extensions;
using OpenClone.Services.Services;
using Pgvector.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI
{
    public class GenerativeImageService
    {
        // todo: 1469-1502 don't have source image id's
        // not important - you will redo that later when you add more images when going to prod. this is a non-issue
        private readonly ConfigurationService _configurationService;
        private readonly CompletionService _openAIService;
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly ILogger _logger;
        private readonly EmbeddingService<GenerativeImage> _embeddingsService;
        private readonly NetworkService _networkService;

        public GenerativeImageService(ConfigurationService configurationService, CompletionService openAIService, ApplicationDbContext applicationDbContext, ILoggerFactory loggerFactory, EmbeddingService<GenerativeImage> embeddingsService, NetworkService networkService)
        {
            _configurationService = configurationService;
            _openAIService = openAIService;
            _applicationDbContext = applicationDbContext;
            _logger = loggerFactory.CreateLogger(GlobalVariables.OpenCloneCategory);
            _embeddingsService = embeddingsService;
            _networkService = networkService;
        }


        private async Task<string> GetGenerativeImageUrl(string prompt, GenerativeImageDimension generativeImageDimension = GenerativeImageDimension._1024x1024, GenerativeImageQuality generativeImageQuality = GenerativeImageQuality.Standard)
        {
            var endpointUrl = "https://api.openai.com/v1/images/generations";
            var data = new
            {
                model = "dall-e-3",
                prompt = prompt,
                n = 1,
                size = generativeImageDimension.GetNormalizedName(),
                quality = generativeImageQuality.GetNormalizedName(), // TODO: im not sure if quality is actually being sent correctly
            };
            return (await _networkService.Post<GenerativeImageDTO>(endpointUrl, data, CustomHeaders.APIKeyOpenAI | CustomHeaders.ExpectJson)).Data[0].Url;
        }

        public async Task<GenerativeImage> FetchOrGenerateImage(GenerativeImageSystemMessage systemMessage, string imageDescription, GenerativeImageDimension generativeImageDimension = GenerativeImageDimension._1024x1024, GenerativeImageQuality generativeImageQuality = GenerativeImageQuality.Standard)
        {
            // first you get the embedding (generativeImage is a subclass of Embedding) --- dont save prompt prefix. the embedding is more generally useful without it.
            var generativeImage = await _embeddingsService.FetchOrGenerateEmbedding(imageDescription, saveIfNew: true);

            // if an image matching the provided description is not found, download one and save it to OpenCloneFS
            var savePath = Path.Join(_configurationService.GetOpenCloneFSPath(), "GenerativeImages", generativeImage.Id + ".png");
            if (!File.Exists(savePath))
            {
                var urlOfGeneratedImage = await GetGenerativeImageUrl($"{systemMessage.GetText()}{imageDescription}", generativeImageDimension, generativeImageQuality);
                await NetworkService.DownloadImage(urlOfGeneratedImage, savePath);
            }

            return generativeImage;
        }

        public async Task<List<GenerativeImage>> GetClosest(string text, int limit = 5)
        {
            // query source images and derived images independently (2x's query time but makes code easier to understand)
            var sourceImages = await _embeddingsService.GetClosest(
                text,
                limit,
                dbSet => { return dbSet.Where(gi => gi.SourceImage == null); },
                saveIfNew: true);

            var derivedImages = await _embeddingsService.GetClosest(
                text,
                limit,
                dbSet => { return dbSet.Where(gi => gi.SourceImage != null); },
                orderedQueryable => orderedQueryable
                    .GroupBy(gi => gi.SourceImage.Id)
                    .Select(g => g.First()),
                saveIfNew: true);

            // combine the results into one list
            var results = new List<GenerativeImage>();
            results.AddRange(sourceImages.Where(gi => gi != null));
            results.AddRange(derivedImages.Where(gi => gi != null));

            // get closest on the combined list and take the limit
            return results
                .OrderBy(gi => gi.Vector.ClientEvaluatedCosineDistance(gi.Vector))
                .Take(limit)
                .ToList();
        }
    }
}