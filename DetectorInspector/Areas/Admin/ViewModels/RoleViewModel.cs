using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.Admin.ViewModels
{
    public class RoleViewModel : ViewModel
    {
		public IEnumerable<ApplicationAreaViewModel> Areas { get; set; }

        public Role Role { get; private set; }

        public RoleViewModel(IRoleRepository roleRepository)
			: this(roleRepository, null)
		{
        }

		public RoleViewModel(IRoleRepository roleRepository, int? roleId)
        {
			if (roleId.HasValue)
			{
				Role = roleRepository.GetRoleWithPermisions(roleId.Value);
			}
			else
			{
				Role = new Role();
			}

			Areas = from a in roleRepository.GetPermissionsByApplicationAreas()
					select new ApplicationAreaViewModel(a.Name, a.Permissions);
		}
    }
}
