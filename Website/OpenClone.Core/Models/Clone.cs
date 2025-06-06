using OpenClone.Core.Attributes;
using OpenClone.Core.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace OpenClone.Core.Models
{
    public class Clone
    {
        public int Id { get; set; }
        [JsonIgnore]
        public string ApplicationUserId { get; set; }
        [JsonIgnore]
        virtual public ApplicationUser ApplicationUser { get; set; }
        public string? VoiceId { get; set; }
        public DateTime CreateDate { get; set; }
        public string? SystemMessage { get; set; }
        public bool AllowLogging { get; set; }
        [SystemMessageData]
        public string FirstName { get; set; }
        [SystemMessageData]
        public string? LastName { get; set; }
        [SystemMessageData]
        public string? NickName { get; set; }
        [SystemMessageData]
        public string? Age { get; set; } // TODO: birthday instead? it's my birthday!
        [SystemMessageData]
        public string? Biography { get; set; }
        [SystemMessageData]
        public string? City { get; set; }
        [SystemMessageData]
        public string? State { get; set; }
        [SystemMessageData]
        public string? Occupation { get; set; }
        public bool? MakePublic { get; set; }
        public int DeepFakeModeLookupId { get; set; }
        virtual public DeepFakeModeLookup DeepFakeMode { get; set; }

    }
}
