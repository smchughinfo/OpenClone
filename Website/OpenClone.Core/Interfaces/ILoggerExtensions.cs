using Microsoft.Extensions.Logging;
using OpenClone.Core.Models;
using OpenClone.Core.Services.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Interfaces
{
    public static class ILoggerExtensions
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="logger"></param>
        /// <param name="imagePath">/OpenCloneFS/{your-image-path}</param>
        /// <param name="caption"></param>
        public static void LogImage(this ILogger logger, string imagePath, string caption)
        {
            imagePath = $"/OpenCloneFS/{imagePath}";
            logger.LogInformation($"<img src='{imagePath}'/><br><q>{caption}</q>");
        }
    }
}
