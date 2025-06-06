using System;

namespace OpenClone.Core.Models.Enums
{
    public class EnumLookup<TEnum> where TEnum : Enum
    {
        private int _id;
        private string _enumName;

        public EnumLookup() { }

        public EnumLookup(int id)
        {
            Id = id;
        }

        public EnumLookup(string enumName)
        {
            EnumName = enumName;
        }

        public int Id
        {
            get => _id;
            set
            {
                if (Enum.IsDefined(typeof(TEnum), value))
                {
                    _id = value;
                    _enumName = Enum.GetName(typeof(TEnum), value);
                }
                else
                {
                    throw new ArgumentException($"Invalid value for {typeof(TEnum).Name}: {value}");
                }
            }
        }

        public string EnumName
        {
            get => _enumName;
            set
            {
                if (Enum.TryParse(typeof(TEnum), value, out _))
                {
                    _enumName = value;
                    _id = (int)Enum.Parse(typeof(TEnum), value);
                }
                else
                {
                    throw new ArgumentException($"Invalid value for {typeof(TEnum).Name}: {value}");
                }
            }
        }

        public TEnum GetEnum()
        {
            return (TEnum)Enum.Parse(typeof(TEnum), EnumName);
        }
    }
}
