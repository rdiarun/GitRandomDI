using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Reflection;
using System.ComponentModel;

namespace DetectorInspector.Infrastructure
{
    public static class EnumHelper
    {
        public static IEnumerable<KeyValuePair<string, string>> GetEnumerationItems<TEnum>() where TEnum : struct
        {
            var type = typeof(TEnum);

            var items = from f in type.GetFields(BindingFlags.Public | BindingFlags.Static)
                        let attributes = f.GetCustomAttributes(typeof(DescriptionAttribute), false)
                        let description = attributes.Length == 1 ? ((DescriptionAttribute)attributes[0]).Description : f.Name
                        select new KeyValuePair<string, string>(f.GetRawConstantValue().ToString(), description);

            return items;
        }

		public static string GetDescription(this Enum value)
		{
			var descriptionAttributes = 
				value.GetType().GetField(value.ToString()).GetCustomAttributes(typeof(DescriptionAttribute), true);

			if (descriptionAttributes.Length > 0)
			{
				return ((DescriptionAttribute)descriptionAttributes[0]).Description;
			}

			return value.ToString();
		}
    }
}