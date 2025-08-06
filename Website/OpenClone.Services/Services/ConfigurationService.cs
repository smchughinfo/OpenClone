using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services
{
    public class ConfigurationService
    {
        private readonly IConfiguration _configuration;
        public ConfigurationService(IConfiguration configuration) 
        {
            _configuration = configuration;
        }

        public string GetOpenCloneFSPath()
        {
            return Environment.GetEnvironmentVariable("OpenClone_OpenCloneFS");
        }

        public string GetSadTalkerHostAddress()
        {
            return Environment.GetEnvironmentVariable("OpenClone_SadTalker_HostAddress");
        }

        public string GetOpenAIKey()
        {
            return Environment.GetEnvironmentVariable("OpenClone_OPENAI_API_KEY");
        }

        public string GetElevenLabsKey()
        {
            return Environment.GetEnvironmentVariable("OpenClone_ElevenLabsAPIKey");
        }

        public string GetJWTokenIssuer()
        {
            return Environment.GetEnvironmentVariable("OpenClone_JWT_Issuer");
        }

        public string GetJWTokenAudience()
        {
            return Environment.GetEnvironmentVariable("OpenClone_JWT_Audience");
        }

        public string GetJWTokenKey()
        {
            return Environment.GetEnvironmentVariable("OpenClone_JWT_SecretKey");
        }

        public string GetU2NetHostName()
        {
            return Environment.GetEnvironmentVariable("OpenClone_U2Net_HostAddress");
        }

        public string GetQuickFakeAudio() 
        {
            return Path.Join(GetOpenCloneFSPath(), "quick-fake-audio.wav");
        }
    }
}
