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
    public class BookingScheduleViewModel : ViewModel
    {
        
		private IRepository _repository;

        public IEnumerable<DetectorInspector.Model.Technician> Technicians { get; private set; }
        public DateTime? BookingDate { get; set; }
        public SelectList TechnicianSelectList { get; private set; }

        public BookingScheduleViewModel(IRepository repository, bool requireSelectLists, bool requireDefaults)
        {
			
			_repository = repository;
            Technicians = new List<DetectorInspector.Model.Technician>();

            if (requireDefaults)
            {
                SetDefaults();
            }


            if (requireSelectLists)
            {
                Initialize();
            }

		}


        private void Initialize()
        {

            TechnicianSelectList = new SelectList(Technicians, "Id", "Name", string.Empty);


        }


		private void SetDefaults()
		{
            BookingDate = DateTime.Today;

            Technicians = (from technician in _repository.GetActiveForList<DetectorInspector.Model.Technician>(null)
                           where technician.DefaultAvailability.Contains(BookingDate.Value.DayOfWeek.ToString()) ||
                             technician.CurrentAvailability.Any(avail => avail.StartDate <= BookingDate.Value && avail.EndDate >= BookingDate.Value)
                           select technician).ToList();
		}
		
    }
}
