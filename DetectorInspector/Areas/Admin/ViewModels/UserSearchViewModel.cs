using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DetectorInspector.ViewModels;
using DetectorInspector.Model;
using DetectorInspector.Data;
using System.Web.Mvc;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.Admin.ViewModels
{
	public class UserSearchViewModel : ViewModel
	{
		public IEnumerable<CheckBoxListItem> Roles { get; private set; }
		
		[BindCollection(typeof(Role))]
		public IList<Role> SelectedRoles { get; private set; }

		public bool? Enabled { get; set; }
		public bool? LockedOut { get; set; }

		public UserSearchViewModel(IRepository repository, bool isBinding)
		{
			SelectedRoles = new List<Role>();

			var roles = repository.GetActiveForList<Role>(null);

			Roles = (from r in roles
					 select new CheckBoxListItem()
					 {
						 Checked = isBinding ? SelectedRoles.Contains(r) : true,
						 Value = r.Id.ToString(),
						 Text = r.Name
					 }).ToList();
		}
	}
}
