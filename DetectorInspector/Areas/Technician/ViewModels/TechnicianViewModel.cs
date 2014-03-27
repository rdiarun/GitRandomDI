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
    public class TechnicianViewModel : ViewModel
    {
        public IEnumerable<CheckBoxListItem> Days { get; private set; }

        [BindEnumCollection(typeof(DayOfWeek))]
        public IList<DayOfWeek> AvailableDays { get; private set; }

        public SelectList States { get; private set; }
        public DetectorInspector.Model.Technician Technician { get; private set; }
        public DetectorInspector.Model.UserProfile Profile { get; private set; }

        [Required(ErrorMessage="Password is required")]
        [StringLength(128, ErrorMessage="Password must be between 8 and 128 characters in length")]
        public string Password { get; set; }

        [DisplayName("Confirm Password")]
        [Required(ErrorMessage="Confirm Password is required")]
        [StringLength( 128, ErrorMessage="Confirm Password must be between 8 and 128 characters in length")]
        public string ConfirmPassword { get; set; }

        public bool IsCreate()
        {
            return Technician.Id == 0;
        }

        public TechnicianViewModel(IRepository repository, ITechnicianRepository technicianRepository, int id)
        {
            if (id!=0)
			{
                Technician = technicianRepository.Get(id);
                Profile = technicianRepository.GetProfile(id);
			}
			else
			{
                Technician = new DetectorInspector.Model.Technician();
			    Technician.IsDeleted = false;
                Profile = new UserProfile();
			}


            var states = repository.GetAllForList<State>();
            int defaultStateId = ApplicationConfig.Current.DefaultStateId;
            int? stateId = null;


            if (Technician.State != null)
            {
                stateId = Technician.State.Id;
            }

            States = new SelectList(states, "Id", "Name", id!=0 ? stateId : defaultStateId);

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
