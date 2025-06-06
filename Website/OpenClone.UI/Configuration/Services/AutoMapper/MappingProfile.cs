using AutoMapper;
using OpenClone.Core.Models;
using OpenClone.Core.Models.Enums;
using OpenClone.Services.Extensions;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;
using OpenClone.UI.Controllers.CloneCRUD.DTOs.Clone_DTO;

namespace OpenClone.UI.Configuration.Services.AutoMapper
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<Create_Clone_DTO, Clone>()
                .ForMember(dest => dest.DeepFakeModeLookupId,
                    opt => opt.MapFrom(src => src.DeepFakeMode))
                .ForMember(dest => dest.DeepFakeMode, opt => opt.Ignore());

            CreateMap<Update_Clone_DTO, Clone>();
            CreateMap<Clone, Get_Clone_DTO>();

            CreateMap<DeepFakeModeLookup, int>().ConstructUsing(d => d.Id);
            // TODO: delete this -> CreateMap<int, DeepFakeModeLookup>().ConstructUsing(id => new DeepFakeModeLookup(id));
        }
    }
}
