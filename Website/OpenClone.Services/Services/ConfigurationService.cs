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
        // TODO: THIS WHOLE THING SHOULD BE A STATIC CLASS LIKE GLOBALVARIABLES.CS. AND THEN OTHER PLACES WHERE YOU DO CALLS TO GETENVIRONMENTVARIABLES CAN USE THIS TOO. ...I GUESS IF YOU WANT TO DO IT RIGHT YOU COULD HAVE ONE AT INFRASTRUCTURE AND UI LEVELS AND ANOTHER AT CORE LEVEL
        // TODO: turn these into properties
        // TODO: MAKE SURE YOU AUTHENTICATE VIDEO STREAMS https://chat.openai.com/share/eb0ca5e6-ada9-4ab9-a0ea-2c7e09f7da38
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
            // TODO: IMPORTANT - set this to a different value in production
            return Environment.GetEnvironmentVariable("OpenClone_JWT_SecretKey");
        }

        public string GetU2NetHostName()
        {
            return Environment.GetEnvironmentVariable("OpenClone_U2Net_HostAddress");
        }

        // TODO: you should really append path to this members in here and in clonemetadataservice that return a file
        public string GetQuickFakeAudio() 
        {
            return Path.Join(GetOpenCloneFSPath(), "quick-fake-audio.wav");
        }
    }
}
