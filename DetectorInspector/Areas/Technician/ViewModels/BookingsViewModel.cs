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

    public class BookingsViewModel : ViewModel
    {
        public IEnumerable<DetectorInspector.Model.Booking> Bookings { get; private set; }

        public BookingsViewModel(DetectorInspector.Model.Technician technician, DateTime date)
        {
            Bookings = from b in technician.ActiveBookings
                       where b.Date.Equals(date)
                       orderby b.Time.HasValue ? b.Time.Value : DateTime.MinValue
                       select b;

		}

    }
}
