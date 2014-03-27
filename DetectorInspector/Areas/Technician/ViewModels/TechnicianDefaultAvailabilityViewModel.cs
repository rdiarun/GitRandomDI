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
    public class TechnicianDefaultAvailabilityViewModel : ViewModel
    {
        public IEnumerable<CheckBoxListItem> Days { get; private set; }

        [BindEnumCollection(typeof(DayOfWeek))]
        public IList<DayOfWeek> AvailableDays { get; private set; }

        public DetectorInspector.Model.Technician Technician { get; private set; }

        public bool IsCreate()
        {
            return Technician.Id == 0;
        }

        public TechnicianDefaultAvailabilityViewModel(IRepository repository, ITechnicianRepository technicianRepository, int id)
        {
            if (id!=0)
			{
                Technician = technicianRepository.Get(id);
			}
			else
			{
                Technician = new DetectorInspector.Model.Technician();
			}

            var days = EnumHelper.GetEnumerationItems<DayOfWeek>();
            var availableDays = new string[0];
            if (Technician.DefaultAvailability != null)
            {
                availableDays = Technician.DefaultAvailability.Split(",".ToCharArray());
            }
            AvailableDays = (from d in days
                               where availableDays.Contains(d.Value)
                             select ((DayOfWeek)Enum.Parse(typeof(DayOfWeek), d.Key))).ToList();

            Days = (from d in days
                      select new CheckBoxListItem()
                      {
                          Checked = AvailableDays.Contains((DayOfWeek)Enum.Parse(typeof(DayOfWeek), d.Key.ToString())),
                          Value = d.Key,
                          Text = d.Value
                      }).ToList();

		}

        public void UpdateModel()
        {
            Technician.DefaultAvailability = string.Join(",", AvailableDays.Select<DayOfWeek, string>(d => d.ToString()).ToArray());
        }
        
    }
}
