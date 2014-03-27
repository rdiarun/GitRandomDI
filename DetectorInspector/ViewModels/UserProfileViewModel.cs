using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using DetectorInspector.Data;
using DetectorInspector.Model;


namespace DetectorInspector.ViewModels
{
	public class UserProfileViewModel : ViewModel
	{
        public UserProfile Profile { get; protected set; }
        public Technician Technician { get; protected set; }

        public UserProfileViewModel(UserProfile userProfile)
        {
            Profile = userProfile;
            if (userProfile.Technician != null)
            {
                Technician = userProfile.Technician;
            }

		}
	}
}
