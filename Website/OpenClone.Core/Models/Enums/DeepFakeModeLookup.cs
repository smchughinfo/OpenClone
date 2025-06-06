using System;
using OpenClone.Core.Extensions;
using OpenClone.Core.Models.Enums;

namespace OpenClone.Core.Models.Enums
{
    // Posgres starts counting at 1
    public enum DeepFakeMode { QuickFake = 1, DeepFake } // Heygen?

    public class DeepFakeModeLookup : EnumLookup<DeepFakeMode>
    {
        public DeepFakeModeLookup() { }
        public DeepFakeModeLookup(int id) : base(id) { }
        public DeepFakeModeLookup(string enumName) : base(enumName) { }
    }
}
