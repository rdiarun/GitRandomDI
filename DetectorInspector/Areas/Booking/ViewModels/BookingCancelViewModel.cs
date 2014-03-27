using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.Booking.ViewModels
{
    public class BookingCancelViewModel : ViewModel
    {
        public DetectorInspector.Model.Booking Booking { get; private set; }
        public string ContactNotes { get; set; }
        public InspectionStatus? InspectionStatus { get; set; }
        public byte[] RowVersion { get; set; }
        

        public BookingCancelViewModel(IRepository repository, IBookingRepository bookingRepository, int id)
        {
            if (id!=0)
			{
                Booking = bookingRepository.Get(id);
			}
			else
			{
                Booking = new DetectorInspector.Model.Booking();
			}

            Booking.RowVersion = RowVersion;

		}
        
    }
}
