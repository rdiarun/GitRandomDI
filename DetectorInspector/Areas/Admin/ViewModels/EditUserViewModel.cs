using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using DetectorInspector.Model.Attributes;

namespace DetectorInspector.Areas.Admin.ViewModels
{
    [PropertiesMustMatch("Password", "ConfirmPassword", ErrorMessage = "Password and Confirm Password do not match")]
	public class EditUserViewModel : ViewModel
	{
        public EditUserViewModel(UserProfile user, IRepository repository)
        {
            Profile = user;

            var roles = repository.GetActiveForList<Role>(null);

            Roles = (from r in roles
                     select new CheckBoxListItem()
                     {
                         Checked = Profile.Roles.Contains(r),
                         Value = r.Id.ToString(),
                         Text = r.Name
                     }).ToList();

        }

        public IEnumerable<CheckBoxListItem> Roles { get; private set; }
        
        public UserProfile Profile { get; set; }

        [Required(ErrorMessage="Password is required")]
        [StringLength(128, ErrorMessage="Password must be between 8 and 128 characters in length")]
        public string Password { get; set; }

        [DisplayName("Confirm Password")]
        [Required(ErrorMessage="Confirm Password is required")]
        [StringLength(128, ErrorMessage="Confirm Password must be between 8 and 128 characters in length")]
        public string ConfirmPassword { get; set; }
	}
}
