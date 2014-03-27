using System;

namespace DetectorInspector.Infrastructure
{
    public interface IModelMetadataProvider
    {
        string GetModelDisplayName(Type modelType);
		string GetModelDisplayName(string modelTypeName);
		string GetModelPropertyDisplayName(Type modelType, string propertyName);
		string GetModelPropertyDisplayName(string modelTypeName, string propertyName);
    }
}
