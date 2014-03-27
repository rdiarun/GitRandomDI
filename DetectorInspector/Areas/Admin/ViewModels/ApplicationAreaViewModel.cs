using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;

namespace DetectorInspector.Areas.Admin.ViewModels
{
	public class ApplicationAreaViewModel
	{
		public string Name { get; set; }
		public IEnumerable<CheckBoxListItem> Permissions { get; private set; }

		public ApplicationAreaViewModel(string name, IEnumerable<PermissionEntity> permissions)
		{
			Name = name;
			Permissions = (from p in permissions
						   select new CheckBoxListItem()
						   {
							   Value = p.Id.ToString(),
							   Text = p.Name
						   }).ToList();
		}
	}
}
