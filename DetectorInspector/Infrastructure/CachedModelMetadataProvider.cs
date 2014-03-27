using System;
using Kiandra.Data;

namespace DetectorInspector.Infrastructure
{
    public class CachedModelMetadataProvider : IModelMetadataProvider
    {
        private readonly SimpleCache<Type, ModelMetadata> _cache;

		private readonly string _assemblyName;
		private readonly string _modelNamespace;

		private const string _assemblyQualifiedTypeNameFormat =
			"{0}.{1}, {2}";

		public CachedModelMetadataProvider(string assemblyName, string modelNamespace)
		{
			_assemblyName = assemblyName;
			_modelNamespace = modelNamespace;

			_cache = new SimpleCache<Type, ModelMetadata>(t => new ModelMetadata(t));
		}

		public string GetModelDisplayName(string modelTypeName)
		{
			var modelType = GetModelType(modelTypeName);

			return GetModelDisplayName(modelType);
		}

        public string GetModelDisplayName(Type modelType)
        {
            var metadata = _cache[modelType];

            return metadata.DisplayName;
        }

		public string GetModelPropertyDisplayName(string modelTypeName, string propertyName)
		{
			var modelType = GetModelType(modelTypeName);

			return GetModelPropertyDisplayName(modelType, propertyName);
		}

        public string GetModelPropertyDisplayName(Type modelType, string propertyName)
        {
            var metadata = _cache[modelType];

            return metadata[propertyName];
        }

		private Type GetModelType(string modelTypeName)
		{
			var typeName =
				string.Format(_assemblyQualifiedTypeNameFormat, _modelNamespace, modelTypeName, _assemblyName);

			return Type.GetType(typeName);
		}
    }
}
