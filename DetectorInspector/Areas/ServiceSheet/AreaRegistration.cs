using System.Web.Mvc;

namespace DetectorInspector.Areas.ServiceSheet
{
    public class ServiceSheetAreaRegistration : AreaRegistration
    {
        public override string AreaName
        {
            get
            {
                return "ServiceSheet";
            }
        }

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.MapRoute(
                "ServiceSheet_default",
                "ServiceSheet/{controller}/{action}/{id}",
                new { action = "Index", id = UrlParameter.Optional }
            );
        }
    }
}
