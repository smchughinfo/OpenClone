using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.Extensions.DependencyInjection;
using OpenClone.Services;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services;
using OpenClone.Services.Services.ElevenLabs;
using OpenClone.Services.Services.OpenAI;
using OpenClone.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using OpenClone.Core.Models;
using OpenClone.Services.Services.Chat;

namespace OpenClone.Services
{
    public static class ServicesSetup
    {
        public static void DoSetup(IServiceCollection services)
        {
            /*
                // Transient: New instance every time it's requested.
                // Scoped: One instance per request.
                // Singleton: One instance for the entire application.
             */

            // SCOPED
            services.AddScoped<QAService, QAService>();
            services.AddScoped<ModerationsService, ModerationsService>();
            services.AddScoped<CompletionService, CompletionService>();
            services.AddScoped<ApplicationUserService, ApplicationUserService>();
            services.AddScoped<CloneCRUDService, CloneCRUDService>();
            services.AddScoped<CloneMetadataService, CloneMetadataService>();
            services.AddScoped<ElevenLabsService, ElevenLabsService>();
            services.AddScoped<RenderingService, RenderingService>();
            services.AddScoped<EmbeddingService<Question>, EmbeddingService<Question>>();
            services.AddScoped<EmbeddingService<Answer>, EmbeddingService<Answer>>();
            services.AddScoped<EmbeddingService<GenerativeImage>, EmbeddingService<GenerativeImage>>();
            services.AddScoped<GenerativeImageService, GenerativeImageService>();
            services.AddScoped<NetworkService, NetworkService>();
            services.AddScoped<ConfigurationService, ConfigurationService>();
            services.AddScoped<DeepFakeOrchestrationService, DeepFakeOrchestrationService>();
            services.AddScoped<ChatService, ChatService>();

            // TRANSIENT
            services.AddTransient<IEmailSender, EmailSenderService>();
            services.AddTransient<AudioService, AudioService>(); 

            // THIRD PARTY
            services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies()); // this also gets done in the UI project, although doing so is redundtant when used with the UI project
        }
    }
}
