using OpenClone;
using OpenClone.Core;
using OpenClone.Core.Extensions;
using OpenClone.Services.Services.OpenAI.Enums;
using OpenClone.Services.Services.OpenAI.Extensions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Services.Services.OpenAI.Extensions
{
    public static class GenerativeImageDimensionExtensions
    {
        public static string GetNormalizedName(this GenerativeImageDimension generativeImageDimension)
        {
            return generativeImageDimension.ToString().Substring(1);
        }
    }
}
