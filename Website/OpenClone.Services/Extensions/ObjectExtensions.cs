using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace OpenClone.Services.Extensions
{
    public static class ObjectExtensions
    {
        /// <param name="onProperty">return true to break</param>
        public static void IterateOverProperties(this object obj, Func<string, object, bool> onProperty)
        {
            foreach(var property in obj.GetType().GetProperties())
            {
                string propertyName = property.Name;
                var propertyValue = property.GetValue(obj);

                var doBreak = onProperty(propertyName, propertyValue);
                if (doBreak) {
                    break;
                }
            }
        }

        public static void IterateOverProperties(this object obj, Action<string, object> onProperty)
        {
            obj.IterateOverProperties((name, value) =>
            {
                onProperty(name, value);
                return false;
            });
        }

        public static void IterateOverProperties<TAttribute>(this object obj, Action<string, object, bool> action) where TAttribute : Attribute
        {
            Type type = obj.GetType();
            PropertyInfo[] properties = type.GetProperties();

            foreach (var property in properties.Where(prop => Attribute.IsDefined(prop, typeof(TAttribute))))
            {
                string propertyName = property.Name;
                object propertyValue = property.GetValue(obj);
                bool isDefaultValue = IsDefaultValue(propertyValue, property.PropertyType);
                action(propertyName, propertyValue, isDefaultValue);
            }
        }

        public static bool IsFileStream(this object obj)
        {
            return (obj is FileStream);
        }

        private static bool IsDefaultValue(object value, Type type)
        {
            if (type.IsValueType)
            {
                return value == Activator.CreateInstance(type);
            }
            return value == null;
        }
    }
}
