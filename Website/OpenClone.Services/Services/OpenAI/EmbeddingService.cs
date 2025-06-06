using Microsoft.EntityFrameworkCore;


using Microsoft.Extensions.Configuration;
using Npgsql;
using OpenClone;
using OpenClone.Core;
using OpenClone.Core.Models;
using OpenClone.Core.Services.Logging;
using OpenClone.Services;
using OpenClone.Services.Services;
using OpenClone.Services.Services.OpenAI;
using OpenClone.Services.Services.OpenAI.DTOs;
using Pgvector;
using Pgvector.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace OpenClone.Services.Services.OpenAI
{
    public class EmbeddingService<T> where T : Embedding, new()
    {
        private readonly NetworkService _networkService;
        private readonly ApplicationDbContext _applicationDbContext;

        private readonly string _endpointUrl = "https://api.openai.com/v1/embeddings";
        public EmbeddingService(NetworkService networkService, ApplicationDbContext applicationDbContext)
        {
            _networkService = networkService;
            _applicationDbContext = applicationDbContext;
        }

        private async Task<T> GenerateEmbedding(string text, Action<T> compositePKSetter = null, bool saveIfNew = false)
        {
            var data = new {
                input = text,
                model =  "text-embedding-3-small"
            };
            var embeddingDto = await _networkService.Post<EmbeddingDTO>(_endpointUrl, data, CustomHeaders.APIKeyOpenAI | CustomHeaders.ExpectJson);
            
            // if record with text but not the actual vector exists set the vector and update. else add a new record with both the text and vector
            var dbEmbedding = _applicationDbContext.Set<T>().SingleOrDefault(e => e.Text == text);

            if (dbEmbedding != null) {
                dbEmbedding.Vector = new Vector(embeddingDto.Data[0].Embedding.ToArray());
            }
            else {
                dbEmbedding = new T { Text = text, Vector = new Vector(embeddingDto.Data[0].Embedding.ToArray()) };

                if (compositePKSetter != null) {
                    compositePKSetter(dbEmbedding);
                }

                if(saveIfNew == false) {
                    return dbEmbedding;
                }

                _applicationDbContext.Add<T>(dbEmbedding);
            }

            await _applicationDbContext.SaveChangesAsync();

                
            return dbEmbedding;
        }

        public async Task<T> FetchOrGenerateEmbedding(string text, Action<T> compositePKSetter = null, bool saveIfNew = false)
        {
            var embedding = await _applicationDbContext.Set<T>().SingleOrDefaultAsync(e => e.Text == text && e.Vector != null);
            if (embedding == null) {
                embedding = await GenerateEmbedding(text, compositePKSetter, saveIfNew);
            }
            return embedding;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="text"></param>
        /// <param name="limit"></param>
        /// <param name="whereConcreteFilter">Allows filtering on properties that aren't part of the base class.</param>
        /// <param name="orderedConcreteFilter">Allows for GroupBy to be called on the query after it's ordered by cosine distance</param>
        /// <param name="saveIfNew">If the text parameter is not found in the database and we have to generate a new one, should we save that new one to the database?</param>
        /// <returns></returns>
        public async Task<List<T>> GetClosest(string text, int limit = 5, Func<DbSet<T>, IQueryable<T>> whereConcreteFilter = null, Func<IOrderedQueryable<T>, IQueryable<T>> orderedConcreteFilter = null, bool saveIfNew = false)
        {
            var embedding = await FetchOrGenerateEmbedding(text, saveIfNew:saveIfNew);
            var dbSet = _applicationDbContext.Set<T>();

            // WHERE PART OF QUERY
            var whereConcreteFiltered = whereConcreteFilter == null ? dbSet : whereConcreteFilter(dbSet);
            var whereQueryable = whereConcreteFiltered
                .Where(e => e.Vector != null && e.Text != text) // make sure it doesnt compare against itself and there is a vector to compare against to so it doesnt crash
                .OrderBy(e => e.Vector.CosineDistance(embedding.Vector));

            // ORDERED PART OF QUERY
            var orderedConcreteFiltered = orderedConcreteFilter == null ? whereQueryable : orderedConcreteFilter(whereQueryable);

            // LIMIT AND RETURN
            return await orderedConcreteFiltered
                .Take(limit)
                .ToListAsync();
        }
    }
}
