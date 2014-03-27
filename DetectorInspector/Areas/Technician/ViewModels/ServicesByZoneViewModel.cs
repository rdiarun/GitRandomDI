using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using DetectorInspector.Infrastructure;
using System.ComponentModel;
using DetectorInspector.Model.Attributes;
using System.Globalization;

namespace DetectorInspector.Areas.Technician.ViewModels
{

    public class ServicesByZoneViewModel : ViewModel
    {
        public string Title { get; set; }
        public IEnumerable<ServiceByZoneResult> Services { get; private set; }

        public ServicesByZoneViewModel(ITechnicianRepository technicianRepository, DateTime dateTime)
        {
            Services = technicianRepository.GetServicesByZone(dateTime);
            Title = string.Format("Services for {0}", CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(dateTime.Month));
		}

    }
}
