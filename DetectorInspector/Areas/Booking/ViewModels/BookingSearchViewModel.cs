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
    public class BookingSearchViewModel : ViewModel
    {
        
		private IRepository _repository;

        public IEnumerable<DetectorInspector.Model.Technician> Technicians { get; private set; }
        public DateTime? BookingDate { get; set; }
        public SelectList TechnicianSelectList { get; private set; }
        public SelectList Durations { get; set; }

        public IEnumerable<RadioButtonListItem> UpdateInspectionStatuses { get; private set; }

        public BookingSearchViewModel(IRepository repository, bool requireSelectLists, bool requireDefaults)
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

            TechnicianSelectList = new SelectList(_repository.GetActiveForList<DetectorInspector.Model.Technician>(null), "Id", "Name", string.Empty);
            Durations = new SelectList(EnumHelper.GetEnumerationItems<Duration>(), "Key", "Value", string.Empty);

            var updateInspectionStatuses = new List<InspectionStatus>()
            {
                InspectionStatus.ReadyForService,
                InspectionStatus.RequireContactUsLetter,
                InspectionStatus.RequireNotificationLetter,
                InspectionStatus.BookViaMobilePhone,
                InspectionStatus.RequireUpdatedDetails,
                InspectionStatus.TenancyDetailsIncorrect
            };


            UpdateInspectionStatuses = (from p in updateInspectionStatuses
                                        select new RadioButtonListItem()
                                        {
                                            Value = p.ToString("D"),
                                            Text = p.GetDescription()
                                        }).ToList();


        }


		private void SetDefaults()
		{
            BookingDate = DateTime.Today;
            Technicians = _repository.GetActiveForList<DetectorInspector.Model.Technician>(null);
		}
		
    }
}
