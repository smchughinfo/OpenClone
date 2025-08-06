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
        public static string CompletionSystemMessage_StarterIdea = "im having trouble answering this question. can you suggest three ways to answer? don't answer the question for me. just come up with things i might want to talk about. keep your response to one sentence and use 1. 2. 3. format, please";
        public static string CompletionContextString_StarterIdea = "you are chatgpt, a helpful ai coding assistant. in this case you are generating content for a website when prompted by the user";

        public static int UserDefinedQuestionCategoryId = 26;

        // LOGGING
        public static string OpenCloneCategory = "Website";
        // must include using Microsoft.Extensions.Logging; in the file that uses this. in .net10+ they have global usings
        
        public static string HelpEmailAddress = "clonezone.me@gmail.com";
    }
}
