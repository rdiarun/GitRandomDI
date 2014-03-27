using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;


namespace DetectorInspector.ViewModels
{
	public class LoginViewModel : ViewModel
	{
		[Required]
		[DisplayName("User name")]
		public string UserName { get; set; }

        [Required]		
		[DataType(DataType.Password)]
		[DisplayName("Password")]
		public string Password { get; set; }
	}
}
