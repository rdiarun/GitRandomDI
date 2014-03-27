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

namespace DetectorInspector.Areas.Technician.ViewModels
{
    [PropertiesMustMatchAttribute("Password", "ConfirmPassword", ErrorMessage = "Password and Confirm Password do not match")]
    public class AvailableTechnicianViewModel : ViewModel
    {
        public IEnumerable<DetectorInspector.Model.Technician> Technicians { get; private set; }
        public DateTime Date { get; private set; }

        public AvailableTechnicianViewModel(IRepository repository, DateTime date)
        {
            Date = date;

            Technicians = (from technician in repository.GetActiveForList<DetectorInspector.Model.Technician>(null)
                          where technician.DefaultAvailability.Contains(Date.DayOfWeek.ToString()) ||
                            technician.CurrentAvailability.Any(avail=>avail.StartDate<=Date && avail.EndDate >= Date)
                           select technician).ToList();

		}
        
    }
}
