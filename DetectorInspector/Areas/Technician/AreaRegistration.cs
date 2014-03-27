﻿using System.Web.Mvc;

namespace DetectorInspector.Areas.Technician
{
    public class TechnicianAreaRegistration : AreaRegistration
    {
        public override string AreaName
        {
            get
            {
                return "Technician";
            }
        }

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.MapRoute(
                "Technician_default",
                "Technician/{controller}/{action}/{id}",
                new { action = "Index", id = UrlParameter.Optional }
            );
        }
    }
}
