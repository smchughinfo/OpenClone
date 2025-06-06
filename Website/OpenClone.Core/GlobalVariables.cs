using Microsoft.Extensions.Logging;
using OpenClone.Core.Services.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core
{
    public static class GlobalVariables
    {
        public static bool InDevEnvironment = false;
        /*public static string CompletionSystemMessage_StarterIdea = "Generate a very short starter idea bullet point (1 short sentence max) for the following question. The idea is to help users brainstorm what they might like to talk about on a QA site. don't start your response with an actual bullet point (*, 1., a., etc.). don't respond as though you are listing out accomplishments like bullet points on a resume. just try to invoke thoughts in people. since you will do this multiple times try to add a little variation to the way you would typically answer this. don't start your response with \"sure!\", \"certainly!\", etc. just write the bullet point. you will be asked different questions using the same prompt prefix over a thousand times so try your best to respond as though you were given a truly random seed. Remember, your job is to generate short ideas to help the user brainstorm how they might want to respond, not answer as if you were the user. don't generate responses that themselves sound like they could be an answer. remember to keep it short. the question is:\n\n";*/
        public static string CompletionSystemMessage_StarterIdea = "im having trouble answering this question. can you suggest three ways to answer? don't answer the question for me. just come up with things i might want to talk about. keep your response to one sentence and use 1. 2. 3. format, please";
        public static string CompletionContextString_StarterIdea = "you are chatgpt, a helpful ai coding assistant. in this case you are generating content for a website when prompted by the user";

        public static int UserDefinedQuestionCategoryId = 26;

        // LOGGING
        public static string OpenCloneCategory = "Website";
        // must include using Microsoft.Extensions.Logging; in the file that uses this. in .net10+ they have global usings
        
        public static string HelpEmailAddress = "admin@clonezone.com";
    }
}
