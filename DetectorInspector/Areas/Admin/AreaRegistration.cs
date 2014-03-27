using System.Web.Mvc;
using System.Configuration;

namespace DetectorInspector.Areas.Admin
{
	public class AdminAreaRegistration : AreaRegistration
	{
		public override string AreaName
		{
			get { return "Admin"; }
		}

		public override void RegisterArea(AreaRegistrationContext context)
		{
			var config = (ApplicationConfig)ConfigurationManager.GetSection("kiandra");

			context.MapRoute(
				"ManageReferenceData",
				"Admin/ReferenceData" + config.MvcFileExtension + "/{entityType}/{action}/{id}",
				new { controller = "ReferenceData", action = "List", id = "", area = "Admin" },
				new [] { "DetectorInspector.Areas.Admin.Controllers" }
			);

			context.MapRoute(
				"ManageReferenceDataHome",
				"Admin/ReferenceData" + config.MvcFileExtension,
				new { controller = "ReferenceData", action = "Index", area = "Admin" },
				new [] { "DetectorInspector.Areas.Admin.Controllers" }
			);

			context.MapRoute(
				"Admin",
				"Admin/{controller}" + config.MvcFileExtension + "/{action}/{id}",
				new { action = "Index", id = "", area = "Admin" },
				new [] { "DetectorInspector.Areas.Admin.Controllers" }
			);
		}
	}
}
