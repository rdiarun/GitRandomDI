using System.Web.Mvc;

namespace DetectorInspector.Areas.PropertyInfo
{
    public class PropertyInfoAreaRegistration : AreaRegistration
    {
        public override string AreaName
        {
            get
            {
                return "PropertyInfo";
            }
        }

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.MapRoute(
                "PropertyInfo_default",
                "PropertyInfo/{controller}/{action}/{id}",
                new { action = "Index", id = UrlParameter.Optional }
            );
        }
    }
}
