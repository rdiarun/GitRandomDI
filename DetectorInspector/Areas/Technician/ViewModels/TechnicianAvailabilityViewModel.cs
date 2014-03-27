using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.Technician.ViewModels
{
    public class TechnicianAvailabilityViewModel : ViewModel
    {

        public DetectorInspector.Model.Technician Technician { get; private set; }
        public TechnicianAvailability TechnicianAvailability { get; private set; }

        public bool IsCreate()
        {
            return TechnicianAvailability.Id == 0;
        }

        public TechnicianAvailabilityViewModel(IRepository repository, DetectorInspector.Model.Technician technician, int id)
        {
            Technician = technician;
            if (id!=0)
			{
                TechnicianAvailability = repository.Get<TechnicianAvailability>(id);
			}
			else
			{
                TechnicianAvailability = new TechnicianAvailability(technician);
			}
		}

        public void UpdateModel()
        {
            if (TechnicianAvailability.StartTime.HasValue)
            {
                if (TechnicianAvailability.StartDate.HasValue)
                {
                    TechnicianAvailability.StartTime = TechnicianAvailability.StartDate.Value.AddHours(TechnicianAvailability.StartTime.Value.Hour).AddMinutes(TechnicianAvailability.StartTime.Value.Minute);
                }
            }

            if (!TechnicianAvailability.EndDate.HasValue)
            {
                TechnicianAvailability.EndDate = TechnicianAvailability.StartDate;
            }


            if (TechnicianAvailability.EndTime.HasValue)
            {
                if (TechnicianAvailability.EndDate.HasValue)
                {
                    TechnicianAvailability.EndTime = TechnicianAvailability.EndDate.Value.AddHours(TechnicianAvailability.EndTime.Value.Hour).AddMinutes(TechnicianAvailability.EndTime.Value.Minute);
                }
            }
        }
    }
}
