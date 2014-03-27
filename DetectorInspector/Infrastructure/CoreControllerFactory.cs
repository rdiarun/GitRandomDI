using System;
using System.Web.Mvc;
using System.Web.Routing;
using Kiandra.Web.Mvc;
using DetectorInspector.Controllers;
using Microsoft.Practices.ServiceLocation;
using DetectorInspector.Areas.Admin.Controllers;
using System.Web;

namespace DetectorInspector.Infrastructure
{
	public class CoreControllerFactory : ServiceLocatorControllerFactory
	{
		private IServiceLocator _serviceLocator;

		public CoreControllerFactory(IServiceLocator serviceLocator)
			: base(serviceLocator)
		{
			_serviceLocator = serviceLocator;
		}

		public override IController CreateController(RequestContext requestContext, string controllerName)
		{
            IController result = null;

            if (string.CompareOrdinal(controllerName, "ReferenceData") == 0)
            {
                var entityTypeName = requestContext.RouteData.Values["entityType"];
                var modelType = Type.GetType("DetectorInspector.Model." + entityTypeName + ", DetectorInspector.Model");

                if (modelType != null && modelType.GetInterface("ILookupEntity") != null)
                {
                    Type controllerType = 
                        typeof(ReferenceDataController<>).MakeGenericType(modelType);

                    result = (IController)_serviceLocator.GetInstance(controllerType);
                }

                if (result == null)
                {
                    result = (IController)_serviceLocator.GetInstance<ReferenceDataController>();
                }
            }
            else
            {
                 result = base.CreateController(requestContext, controllerName);
            }


            if (result == null)
            {
                throw new HttpException(404, "File not found");
            }

            return result;
		}
	}
}
