using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;

namespace DetectorInspector.Infrastructure
{
    public class ModelMetadata
    {
        private Type _type;
        private string _modelDisplayName;
        
        private IDictionary<string, string> _propertyDisplayNames = new Dictionary<string, string>();

        public ModelMetadata(Type modelType)
        {
            _type = modelType;

            ExtractModelDisplayName();
			ExtractPropertyDisplayNames();
        }

        /// <summary>
        /// Extracts the value of the DisplayNameAttribute from the model.
        /// </summary>
        private void ExtractModelDisplayName()
        {
            var displayNameAttributes = _type.GetCustomAttributes(typeof(DisplayNameAttribute), true);

            if (displayNameAttributes.Length == 0)
            {
                _modelDisplayName = _type.Name;
            }
            else
            {
                _modelDisplayName = ((DisplayNameAttribute)displayNameAttributes[0]).DisplayName;
            }
        }

        /// <summary>
        /// Extracts the value of the DisplayNameAttributes for each of the properties on the model.
        /// </summary>
        private void ExtractPropertyDisplayNames()
        {
            var properties = _type.GetProperties(BindingFlags.Public | BindingFlags.Instance);

            foreach (var property in properties)
            {
                var displayNameAttributes = property.GetCustomAttributes(typeof(DisplayNameAttribute), true);
                string displayName;

                if (displayNameAttributes.Length == 0)
                {
                    displayName = property.Name;
                }
                else
                {
                    displayName = ((DisplayNameAttribute)displayNameAttributes[0]).DisplayName;
                }

                _propertyDisplayNames.Add(property.Name, displayName);
            }
        }

        /// <summary>
        /// Gets the value of the DisplayNameAttribute for the model.
        /// </summary>
        public string DisplayName
        {
            get { return _modelDisplayName; }
        }

        /// <summary>
        /// Gets the value of the DisplayNameAttribute for the specified property.
        /// </summary>
        /// <param name="propertyName">Name of the property.</param>
        /// <returns>User friendly display name for the property.</returns>
        public string this [string propertyName]
        {
            get { return _propertyDisplayNames[propertyName]; }
        }
    }
}
