using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using OpenClone;
using OpenClone.Core;
using OpenClone.Core.DTOs;
using OpenClone.Core.Interfaces;
using OpenClone.Core.Models;
using OpenClone.Services;
using OpenClone.Services.Services.OpenAI;
using OpenClone.Services.Services.OpenAI.Enums;
using OpenClone.Services.Services.OpenAI.Extensions;
using OpenClone.Services.Services;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace OpenClone.Services.Services
{

    // THIS PLUS THE ANSWER SERVICE NEEDS A REFACTOR OF EPIC PROPORTIONS
    /*
     * THESE ONES I MEAN ---- THIS MESS NEEDS A COMPREHENSIVE REFACTOR
     services.AddScoped<EmbeddingService<Question>, EmbeddingService<Question>>();
            services.AddScoped<EmbeddingService<Answer>, EmbeddingService<Answer>>();
     */

    // TODO: BIG TODO: its too easy here to forget that user defined questions sit next to system questions. Could be a security problem if you allow user a to view user b's user defined questions. ...this whole needs to be broken up into multiple services
    public class QAService
    {
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly ApplicationUserService _applicationUserService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly GenerativeImageService _generativeImageService;
        private readonly ILogger _logger;
        private readonly EmbeddingService<Question> _questionEmbeddingService;
        private readonly EmbeddingService<Answer> _answerEmbeddingService;
        private readonly CompletionService _cs; // todo: deleteme
        private readonly ModerationsService _moderationsService;
        private readonly EmbeddingService<Answer> _answerService;

        public QAService(ApplicationDbContext applicationDbContext, ApplicationUserService userService, IHttpContextAccessor httpContextAccessor, GenerativeImageService generativeImageService, ILoggerFactory loggerFactory, EmbeddingService<Question> questionEmbeddingService, EmbeddingService<Answer> answerEmbeddingService, CompletionService cs, ModerationsService moderationsService, EmbeddingService<Answer> answerService)
        {
            _applicationDbContext = applicationDbContext;
            _applicationUserService = userService;
            _httpContextAccessor = httpContextAccessor;
            _generativeImageService = generativeImageService;
            _logger = loggerFactory.CreateLogger(GlobalVariables.OpenCloneCategory);
            _questionEmbeddingService = questionEmbeddingService;
            _answerEmbeddingService = answerEmbeddingService;
            _cs = cs;
            _moderationsService = moderationsService;
            _answerService = answerService;
        }

        public List<QuestionCategory> GetQuestionCategories()
        {
            return _applicationDbContext.QuestionCategory.ToList();
        }

        public async Task<Dictionary<string, string>> GetRelatedQA(int cloneId, string textToRelate)
        {
            // actual code
            var searchResultsList = await _answerService.GetClosest(textToRelate, 10, dbSet => dbSet.Where(a => a.CloneId == cloneId), saveIfNew: false);
            var searchResults = new Dictionary<string, string>();
            foreach (var searchResult in searchResultsList)
            {
                searchResults.Add(searchResult.Question.Text, searchResult.Text);
            }

            return searchResults;
        }

        private async Task<Question> CreateCustomQuestion(int cloneId, string questionText)
        {
            // MODERATION
            await AuthorizeModeration(questionText);

            // GUARDS
            questionText = questionText.Trim();
            if (questionText == "")
            {
                throw new Exception("No question provided");
            }

            var questionAlreadyExists = _applicationDbContext.Question.SingleOrDefault(q => q.CloneId == cloneId && q.Text == questionText) != null;
            if (questionAlreadyExists)
            {
                throw new Exception($"Question \"{questionText}\" already exists");
            }

            // CREATE QUESTION
            var newQuestion = new Question
            {
                QuestionCategoryId = GlobalVariables.UserDefinedQuestionCategoryId,
                CloneId = cloneId,
                Text = questionText
            };

            _applicationDbContext.Question.Add(newQuestion);
            await _applicationDbContext.SaveChangesAsync();

            // GET EMBEDDINGS FOR QUESTION
            await _questionEmbeddingService.FetchOrGenerateEmbedding(
                questionText,
                q => { q.CloneId = cloneId; q.Text = questionText; },
                true
            );

            // ADD STARTER IDEAS (mainly just getting these so i don't have to redesign the starter ideas section of answer.jsx)
            var starterIdeas = await GetQuestionStarterIdeas(questionText);
            newQuestion.StarterIdea1 = starterIdeas[0];
            newQuestion.StarterIdea2 = starterIdeas[1];
            newQuestion.StarterIdea3 = starterIdeas[2];
            await _applicationDbContext.SaveChangesAsync();

            return newQuestion;
        }

        public async Task<Answer> CreateOrUpdateAnswer(int cloneId, int questionId, string answer)
        {
            // first save answer without embedding.
            // next get embedding - match it on answertext + cloneid of the saved answer

            answer = answer.Trim();

            await AuthorizeModeration(answer);

            var answerToSave = await _applicationDbContext.Answer.FindAsync(cloneId, questionId);

            if (answerToSave == null)
            {
                answerToSave = new Answer
                {
                    QuestionId = questionId,
                    CloneId = cloneId
                };
                await _applicationDbContext.AddAsync(answerToSave);
            }

            answerToSave.Text = answer;
            answerToSave.AnswerDate = DateTime.UtcNow;
            await _applicationDbContext.SaveChangesAsync();

            // update record with the embedding
            await _answerEmbeddingService.FetchOrGenerateEmbedding(
                answerToSave.Text,
                a => { a.Text = answerToSave.Text; a.CloneId = cloneId; },
                true
            );

            return answerToSave;
        }

        public async Task CreateCustomQA(int cloneId, string questionText, string answerText)
        {
            await AuthorizeModeration(answerText); // serious need of refactor. authorize here and in both of the following method calls. authorize here so we don't create a orphaned question
            // would manifest as: user changes answer to something more appropriate - then it says question already exists. confusing and frustrating. 
            var newQuestion = await CreateCustomQuestion(cloneId, questionText);
            await CreateOrUpdateAnswer(cloneId, newQuestion.Id, answerText);
        }

        public async Task DeleteAnswer(int cloneId, int questionId)
        {
            // delete answer
            var answerToDelete = await _applicationDbContext.Answer.FindAsync(cloneId, questionId);
            _applicationDbContext.Answer.Remove(answerToDelete);

            // delete question if this was a user defined question
            var question = await _applicationDbContext.Question.SingleAsync(q => q.Id == questionId);
            if (question.CloneId == cloneId)
            {
                _applicationDbContext.Question.Remove(question);
            }

            // save changes 
            await _applicationDbContext.SaveChangesAsync();

        }

        public async Task<int> GetQuestionCategoryId(string categoryName)
        {
            return (await _applicationDbContext.QuestionCategory.SingleAsync(c => c.Name == categoryName)).Id;
        }

        public List<int> GetCategoryQuestionIds(int questionCategoryId, int? cloneId = null)
        {
            return _applicationDbContext.Question
            .Where(q =>
                q.QuestionCategoryId == questionCategoryId
            //&& q.CloneId == cloneId
            )
            .Select(q => q.Id)
            .ToList();
        }

        public List<Question> GetAllSystemQuestions()
        {
            return _applicationDbContext.Question.Where(q => q.CloneId == null).ToList();
        }

        // TODO: again - this service needs a refactor. we have GetAnswersForQuestionCategory GetAllQuestionsWithAnswers, and GetAllAnswers which do very similiar things.
        public List<Answer> GetAnswersForQuestionCategory(int cloneId, int questionCategoryId)
        {
            var categoryQuestionIds = GetCategoryQuestionIds(questionCategoryId, cloneId);

            return _applicationDbContext.Answer.Where(a =>
                a.CloneId == cloneId &&
                categoryQuestionIds.Contains(a.QuestionId)
            ).ToList();
        }

        public List<Answer> GetAllAnswers(int cloneId)
        {
            return _applicationDbContext.Answer.Where(a =>
                a.CloneId == cloneId
            ).ToList();
        }

        public async Task<int> AnswerCount(int cloneId)
        {
            return await _applicationDbContext.Answer.CountAsync(a =>
                a.CloneId == cloneId
            );
        }

        public async Task<List<QuestionWithAnswer_DTO>> GetAllQuestionsWithAnswerStatus(int cloneId)
        {
            var allQuestions = new List<QuestionWithAnswer_DTO>();
            var questionCategories = GetQuestionCategories().Select(c => c.NameToUrlFriendly()).ToList();
            foreach (var category in questionCategories)
            {
                var categoryQuestions = await GetQuestionsWithAnswerStatusInCategory(cloneId, category);
                allQuestions.AddRange(categoryQuestions);
            }
            return allQuestions;
        }

        public List<QuestionWithAnswer_DTO> OrderByRoundRobin(List<QuestionWithAnswer_DTO> questions)
        {
            var orderedQuestions = new List<QuestionWithAnswer_DTO>();
            var categories = questions.GroupBy(q => q.CategoryName).Select(g => g.Key).ToList();
            while (questions.Count != 0)
            {
                foreach (var category in categories.ToList())
                {
                    var nextQuestion = questions.FirstOrDefault(q => q.CategoryName == category);
                    if (nextQuestion != null)
                    {
                        orderedQuestions.Add(nextQuestion);
                        questions.Remove(nextQuestion);
                    }
                }
            }

            return orderedQuestions;
        }

        public async Task<List<QuestionWithAnswer_DTO>> GetQuestionsWithAnswerStatusInCategory(int cloneId, string categoryName)
        {
            // get category questions
            var questionsInCategory = GetQuestionsInCategory(categoryName);

            // get user answers
            categoryName = QuestionCategory.UrlFriendlyToName(categoryName);
            var categoryId = await GetQuestionCategoryId(categoryName);
            var answersInCategory = GetAnswersForQuestionCategory(cloneId, categoryId);

            // combine into dto and return
            return CreateQuestionWithAnswerStatus_DTOs(questionsInCategory, answersInCategory);
        }

        private List<QuestionWithAnswer_DTO> CreateQuestionWithAnswerStatus_DTOs(List<Question> questions, List<Answer> answers)
        {
            return questions.Select(q =>
            {
                var answer = answers.SingleOrDefault(a => a.Question.Id == q.Id);
                return new QuestionWithAnswer_DTO(q, answer);
            }).ToList();
        }

        public async Task<List<string>> GetQuestionStarterIdeas(string questionText)
        {
            var results = new List<string>();

            var completion = await _cs.GetChatCompletion(GlobalVariables.CompletionContextString_StarterIdea, $"{GlobalVariables.CompletionSystemMessage_StarterIdea}\"{questionText}\"");
            string[] splitPattern = Regex.Split(completion, @"(?=\d\.\s)");

            splitPattern = splitPattern.Where(s => !s.IsNullOrEmpty()).ToArray();
            foreach (string idea in splitPattern)
            {
                var normalized = idea.Replace("\r", "").Replace("\n", "").Replace("1.", "").Replace("2.", "").Replace("3.", "").Trim();
                results.Add(normalized);
            }

            if (results.Count != 3)
            {
                throw new OpenCloneException(OpenCloneException.GENERATE_QUESTION_STARTER_IDEAS_FAILED, true);
            }

            return results;
        }

        public async Task<List<QuestionWithAnswer_DTO>> GetSimiliarQuestionsWithAnswerStatus(int cloneId, int questionId)
        {
            var question = await _applicationDbContext.Question.SingleAsync(q => q.Id == questionId);
            AuthorizeQuestionAccess(question.Id, cloneId);
            var relatedQuestions = await _questionEmbeddingService.GetClosest(question.Text, 3, saveIfNew: true);
            var relatedQuestionIds = relatedQuestions.Select(q => q.Id).ToList();
            var answersToRelatedQuestions = await _applicationDbContext.Answer
                .Where(a => a.CloneId == cloneId && relatedQuestionIds.Contains(a.QuestionId))
                .ToListAsync();
            return CreateQuestionWithAnswerStatus_DTOs(relatedQuestions, answersToRelatedQuestions);
        }

        public async Task<List<QuestionWithAnswer_DTO>> GetAllQuestionsWithAnswers(int cloneId)
        {
            var answers = await _applicationDbContext.Answer
                .Where(a => a.CloneId == cloneId)
                .OrderByDescending(a => a.AnswerDate)
                .ToListAsync();

            var questionWithAnswers = new List<QuestionWithAnswer_DTO>();

            foreach (var answer in answers)
            {
                var question = await _applicationDbContext.Question
                    .FirstOrDefaultAsync(q => q.Id == answer.QuestionId);
                questionWithAnswers.Add(new QuestionWithAnswer_DTO(question, answer));
            }

            return questionWithAnswers;
        }

        public List<Answer> GetAnswersSince(int cloneId, DateTime oldestAnswerDate)
        {
            return _applicationDbContext.Answer.Where(a =>
                a.CloneId == cloneId &&
                a.AnswerDate > oldestAnswerDate
            ).ToList();
        }

        public List<Question> GetUnansweredQuestionsInAllSystemCategories(int cloneId)
        {
            var unansweredQuestions = new List<Question>();

            var qc = _applicationDbContext.QuestionCategory.ToList();
            foreach (var questionCategory in qc)
            {
                var answeredQuestionsInCategory = GetAnswersForQuestionCategory(cloneId, questionCategory.Id);
                var unansweredQuestionsInCategory = questionCategory.Questions.Where(q => !answeredQuestionsInCategory.Any(a => a.QuestionId == q.Id)).ToList();
                unansweredQuestions.AddRange(unansweredQuestionsInCategory);
            }

            return unansweredQuestions;
        }

        public List<Question> GetQuestionsInCategory(string categoryName)
        {
            categoryName = QuestionCategory.UrlFriendlyToName(categoryName);
            var questionCategory = _applicationDbContext.QuestionCategory.Single(c => c.Name == categoryName);
            return questionCategory.Questions.Where(q => questionCategory.Id == q.QuestionCategoryId).ToList();
        }

        public List<Question> GetUnansweredQuestionsInCategory(int cloneId, string categoryName)
        {
            categoryName = QuestionCategory.UrlFriendlyToName(categoryName);
            var questionCategory = _applicationDbContext.QuestionCategory.Single(c => c.Name == categoryName);
            var answeredQuestionsInCategory = GetAnswersForQuestionCategory(cloneId, questionCategory.Id);
            return questionCategory.Questions.Where(q => !answeredQuestionsInCategory.Any(a => a.QuestionId == q.Id)).ToList();
        }

        public List<Question> GetUnansweredQuestionsInCategory(int cloneId, int questionCategoryId)
        {
            var questionCategory = _applicationDbContext.QuestionCategory.Single(c => c.Id == questionCategoryId);
            var answeredQuestionsInCategory = GetAnswersForQuestionCategory(cloneId, questionCategory.Id);
            return questionCategory.Questions.Where(q => !answeredQuestionsInCategory.Any(a => a.QuestionId == q.Id)).ToList();
        }

        /// <summary>
        /// Throws exception if question belongs to another user
        /// </summary>
        private void AuthorizeQuestionAccess(int questionId, int cloneId)
        {
            // TODO: i went through the list and made sure we would not serve user defined questions (or their derivatives, like this) of user A to user B but this is an obvious ongoing risk. could forget to do it in the future. should probably add another service to fix this security risk somehow....
            var question = _applicationDbContext.Question.SingleOrDefault(q => q.Id == questionId);
            if (question == null)
            {
                return;
            }

            var systemQuestion = question.CloneId == null;
            var usersQuestion = question.CloneId == cloneId;
            if (!systemQuestion && !usersQuestion)
            {
                throw new Exception("Unauthorized Question");
            }
        }

        private async Task AuthorizeModeration(string text)
        {
            var willBeFlagged = await _moderationsService.WillBeFlagged(text);
            if (willBeFlagged)
            {
                throw new OpenCloneException($"Cannot Proceed; Message flagged by OpenAI. Message: \"{text}\"", true);
            }
        }

        public async Task<List<string>> GetQuestionImages(int idOfCloneRequestingImages, int questionId)
        {
            // TODO: THIS SHOULD SEARCH FOR MORE THAN GENERATED IMAGES. include images they upload, etc. in the mix as well. ....this should be in a service that figures all that magic out. this is a "proto" code
            var question = await _applicationDbContext.Question.FindAsync(questionId);
            AuthorizeQuestionAccess(question.Id, idOfCloneRequestingImages);
            var questionText = question.Text;
            var closestImages = await _generativeImageService.GetClosest(questionText, 3);
            // todo: remove
            foreach (var img in closestImages)
            {
                _logger.LogImage(img.Path.Replace("/OpenCloneFS/", ""), $"Question Text: {questionText}<hr>Image Text: {img.Text}<hr>");
            }
            return closestImages.Select(i => i.Path).ToList();
        }
    }
}