using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using OpenClone.Core.Attributes;
using OpenClone.Core.Models;

namespace OpenClone.Core.Services.AutoMapper
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            MapStringToTrimmedString();
        }

        private void MapStringToTrimmedString()
        {
            CreateMap<string, string>()
                .ConvertUsing(str => str == null ? null : str.Trim());
        }
    }
}
