using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;

namespace DetectorInspector.Areas.Booking.ViewModels
{
    public class BookingViewModel : ViewModel
    {
        public Model.Booking Booking { get; private set; }
        public SelectList Technicians { get; set; }
        public SelectList Durations { get; set; }
        public SelectList Times { get; set; }

        public bool IsCreate()
        {
            return Booking.Id == 0;
        }

        public BookingViewModel(IRepository repository, IBookingRepository bookingRepository, IPropertyRepository propertyRepository, int? propertyInfoId, int id)
        {
            if (id != 0)
            {
                Booking = bookingRepository.Get(id);
                AssignKeyNumber(Booking.PropertyInfo);
            }
            else
            {
                if (propertyInfoId.HasValue)
                {
                    var propertyInfo = propertyRepository.Get(propertyInfoId.Value);
                    Booking = new Model.Booking(propertyInfo);
                    AssignKeyNumber(propertyInfo);
                }
                else
                {
                    Booking = new Model.Booking();
                }
            }

            int? technicianId = null;
            if (Booking.Technician != null)
            {
                technicianId = Booking.Technician.Id;
            }

            Technicians = new SelectList(repository.GetActiveForList<DetectorInspector.Model.Technician>(technicianId).Where(x => x.IsApproved), "Id", "Name", technicianId.HasValue ? technicianId.ToString() : string.Empty);
            Durations = new SelectList(EnumHelper.GetEnumerationItems<Duration>(), "Key", "Value", string.Empty);
        }

        private void AssignKeyNumber(Model.PropertyInfo propertyInfo)
        {
            if (!String.IsNullOrEmpty(propertyInfo.KeyNumber) && (String.IsNullOrEmpty(Booking.KeyNumber)))
            {
                Booking.KeyNumber = propertyInfo.KeyNumber;
            }

        }
    }
}
