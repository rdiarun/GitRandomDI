using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using DetectorInspector.Model;
using System.Web.Security;
using DetectorInspector.Model.Attributes;

namespace DetectorInspector.ViewModels
{
    [PropertiesMustMatch("Password", "ConfirmPassword", ErrorMessage = "Password and Confirm Password do not match")]
	public class ChangePasswordViewModel : ViewModel
	{
        [DataType(DataType.Password)]        
        [DisplayName("Current password")]
        [Required(ErrorMessage="Current password is required")]      
        public string ExistingPassword { get; set; }

        [DataType(DataType.Password)]
        [DisplayName("New Password")]
        [Required(ErrorMessage="New Password is required")]        
        [ValidatePassword()]
        public string Password { get; set; }

        [DataType(DataType.Password)]
        [DisplayName("Confirm Password")]
        [Required(ErrorMessage="Confirm Password is required")]        
        public string ConfirmPassword { get; set; }
	}
}
