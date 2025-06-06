using OpenClone;
using OpenClone.Services;
using OpenClone.Services.Services.OpenAI.Enums;
using OpenClone.Services.Services.OpenAI.Extensions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI.Extensions
{
    public static class GenerativeImageQualityExtensions
    {
        public static string GetNormalizedName(this GenerativeImageQuality generativeImageQuality)
        {
            return generativeImageQuality.ToString().ToLower();
        }
    }
}
