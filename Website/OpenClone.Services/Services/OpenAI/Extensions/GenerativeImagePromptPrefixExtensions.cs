using OpenClone.Services.Services.OpenAI.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI.Extensions
{
    public static class GenerativeImageSystemMessageExtensions
    {
        public static string GetText(this GenerativeImageSystemMessage systemMessage)
        {
            if (systemMessage == GenerativeImageSystemMessage.QuestionCategory) {
                return "can you generate a background image for this concept. it's for a question/answer website. do photorealistic images of people if possible. The concept is:\n\n";
            }
            else if (systemMessage == GenerativeImageSystemMessage.Question) {
                return "can you generate a background image to go with this question on a question/answer website. please don't use text to spell anything:\n\n ";
            }

            throw new Exception("prompt prefix enum not found.");
        }
    }
}
