//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Web;

//namespace DetectorInspector.Infrastructure.HtmlHelpers
//{
//    public static class BreadcrumbHtmlExtensions
//    {
//        private const string BREADCRUMB_SEPERATOR = "&nbsp;&gt;&nbsp;";
//        private const string ANCHOR_FORMAT = "<a href=\"{0}\"{1}>{2}</a>";
//        private const string CLASS_FORMAT = " class=\"{0}\"";

//        public static string Breadcrumb(this HtmlHelper html, string resourceClassKey, string resourceKeyPrefix, object dataValues)
//        {
//            var items = GetBreadcrumbItems(html, dataValues);

//            ApplyDisplayNames(html, items, resourceClassKey, resourceKeyPrefix);

//            var result = string.Empty;
//            var delimiter = string.Empty;

//            var lastItem = items[items.Count - 1];

//            lastItem.Class = "last";
//            lastItem.Url = string.Empty;

//            foreach (var item in items)
//            {
//                if (string.IsNullOrEmpty(item.Url))
//                {
//                    result += delimiter + item.LinkText;
//                }
//                else
//                {
//                    string cssClass = string.Empty;

//                    if (!string.IsNullOrEmpty(item.Class))
//                    {
//                        cssClass = string.Format(CLASS_FORMAT, item.Class);
//                    }

//                    result += delimiter + string.Format(ANCHOR_FORMAT, item.Url, cssClass, item.LinkText);
//                }

//                delimiter = BREADCRUMB_SEPERATOR;
//            }

//            return result;
//        }

//        private static void ApplyDisplayNames(HtmlHelper html, IList<BreadcrumbItem> items, string resourceClassKey, string resourceKeyPrefix)
//        {
//            foreach (var item in items)
//            {
//                var displayText =
//                    (string)html.ViewContext.HttpContext.GetGlobalResourceObject(resourceClassKey, resourceKeyPrefix + item.ResourceKey);

//                if (!string.IsNullOrEmpty(displayText))
//                {
//                    item.LinkText = displayText;
//                }
//                else
//                {
//                    item.LinkText = item.ResourceKey;
//                }
//            }
//        }

//        private static IList<BreadcrumbItem> GetBreadcrumbItems(HtmlHelper html, object dataValues)
//        {
//            var items = new List<BreadcrumbItem>();

//            var areaRouteValue = (string)html.ViewContext.RouteData.Values["area"];
//            var controllerRouteValue = (string)html.ViewContext.RouteData.Values["controller"];
//            var actionRouteValue = (string)html.ViewContext.RouteData.Values["action"];

//            var routeCollection = html.RouteCollection;
//            var requestContext = html.ViewContext.RequestContext;

//            if (string.CompareOrdinal(areaRouteValue, "Default") == 0)
//            {
//                areaRouteValue = "";
//            }

//            items.Add(new BreadcrumbItem()
//            {
//                Url = AreaViewEngine.GetActionUrl(routeCollection, requestContext, "Home", "Index", "Default", dataValues),
//                ResourceKey = "Home/Index"
//            });

//            if (!string.IsNullOrEmpty(areaRouteValue))
//            {
//                string[] areas = areaRouteValue.Split('/');
//                string area = string.Empty;

//                for (var i = 0; i < areas.Length; i++)
//                {
//                    if (area == string.Empty)
//                    {
//                        area = areas[i];
//                    }
//                    else
//                    {
//                        area += "/" + areas[i];
//                    }

//                    items.Add(new BreadcrumbItem()
//                    {
//                        Url = AreaViewEngine.GetActionUrl(routeCollection, requestContext, "Home", "Index", area, dataValues),
//                        ResourceKey = GetResourceKey(area, "Home", "Index")
//                    });
//                }
//            }

//            if (string.CompareOrdinal(controllerRouteValue, "Home") != 0)
//            {
//                items.Add(new BreadcrumbItem()
//                {
//                    Url = AreaViewEngine.GetActionUrl(routeCollection, requestContext, controllerRouteValue, "Index", areaRouteValue, dataValues),
//                    ResourceKey = GetResourceKey(areaRouteValue, controllerRouteValue, "Index")
//                });
//            }

//            if (string.CompareOrdinal(actionRouteValue, "Index") != 0)
//            {
//                items.Add(new BreadcrumbItem()
//                {
//                    Url = AreaViewEngine.GetActionUrl(routeCollection, requestContext, controllerRouteValue, actionRouteValue, areaRouteValue, dataValues),
//                    ResourceKey = GetResourceKey(areaRouteValue, controllerRouteValue, actionRouteValue)
//                });
//            }

//            return items;
//        }

//        private static string GetResourceKey(string area, string controller, string action)
//        {
//            if (string.CompareOrdinal(area, "Default") == 0)
//            {
//                area = "";
//            }
//            else
//            {
//                area += "/";
//            }

//            return area + controller + "/" + action;
//        }

//        private class BreadcrumbItem
//        {
//            public string Url { get; set; }
//            public string ResourceKey { get; set; }
//            public string LinkText { get; set; }
//            public string Class { get; set; }
//        }
//    }
//}
