using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using DetectorInspector.Model;

namespace DetectorInspector.ViewModels
{
    public class RegisterViewModel : ViewModel
    {
        public RegisterViewModel(UserProfile userProfile)
        {
            Profile = userProfile;
        }

        public UserProfile Profile { get; set; }

        [Required]
        [StringLength(20)]
        [DataType(DataType.Password)]
        [DisplayName("Password")]
        public string Password { get; set; }

        [Required]
        [StringLength(20)]
        [DataType(DataType.Password)]
        [DisplayName("Password Confirm")]
        public string PasswordConfirm { get; set; }  
    }
}