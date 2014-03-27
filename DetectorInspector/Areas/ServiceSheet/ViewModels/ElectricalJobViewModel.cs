using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.ServiceSheet.ViewModels
{
    public class ElectricalJobViewModel : ViewModel
    {
        public IEnumerable<DetectorType> DetectorTypes { get; private set; }
        public SelectList Durations { get; private set; }
        public DetectorInspector.Model.Booking Booking { get; private set; }
        public DetectorInspector.Model.ServiceSheet ServiceSheet { get; private set; }
        
        public bool IsCreate()
        {
            return Booking.Id == 0;
        }

        public ElectricalJobViewModel(IRepository repository, IBookingRepository bookingRepository, int id)
        {
            Booking = bookingRepository.GetElectricalJob(id);
            ServiceSheet = bookingRepository.GetServiceSheet(id);
            DetectorTypes = repository.GetAllForList<DetectorType>();
            Durations = new SelectList(EnumHelper.GetEnumerationItems<Duration>(), "Key", "Value", string.Empty);
		}
    }
}
