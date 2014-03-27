using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace DetectorInspector.ViewModels
{
	public class ForgottenPasswordViewModel : ViewModel
	{
		[Required]
		[StringLength(20)]
		[DisplayName("User name")]
		public string UserName { get; set; }
	}
}