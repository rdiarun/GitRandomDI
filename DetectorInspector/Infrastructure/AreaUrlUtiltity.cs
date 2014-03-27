using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;
using System.Web.Mvc;
using Kiandra.Web.Mvc;

namespace DetectorInspector.Infrastructure
{
	public class AreaUrlUtiltity
	{
		public static string GetActionUrl(
			RouteCollection routeCollection,
			RequestContext requestContext,
			string controller,
			string action,
			string area,
			object dataValues)
		{
			var routeValues = new RouteValueDictionary(dataValues);

			if (string.IsNullOrEmpty(controller))
			{
				controller = (string)requestContext.RouteData.Values["controller"];
			}

			if (string.IsNullOrEmpty(action))
			{
				action = (string)requestContext.RouteData.Values["action"];
			}

			if (string.IsNullOrEmpty(area))
			{
				area = (string)requestContext.RouteData.Values["area"];

				if (string.IsNullOrEmpty(area))
				{
					area = "Default";
				}
			}

			routeValues.Add("controller", controller);
			routeValues.Add("action", action);
			routeValues.Add("area", area);

			return routeCollection.GetVirtualPath(requestContext, routeValues).VirtualPath;
		}
	}
}
