using System.Web.Mvc;

namespace DetectorInspector.Areas.Files
{
    public class FilesAreaRegistration : AreaRegistration
    {
        public override string AreaName
        {
            get
            {
                return "Files";
            }
        }

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.MapRoute(
                "Files",
                "Files/{controller}/{action}/{id}",
                new { controller = "Home", action = "Index", id = "" },
                new[] { "DetectorInspector.Areas.Files.Controllers" }
            );
        }
    }
}
