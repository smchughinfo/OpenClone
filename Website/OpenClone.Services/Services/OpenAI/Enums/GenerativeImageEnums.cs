using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI.Enums
{
    public enum GenerativeImageDimension
    {
        _1024x1024,
        _1024x1792,
        _1792x1024
    }

    public enum GenerativeImageQuality
    {
        Standard,
        HD
    }

    public enum GenerativeImageSystemMessage
    {
        Question,
        QuestionCategory
    }
}
