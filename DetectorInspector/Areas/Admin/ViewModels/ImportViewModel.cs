using System;
using System.ComponentModel;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using DetectorInspector.Infrastructure;
using System.Collections.Generic;
using System.Linq;

namespace DetectorInspector.Areas.Admin.ViewModels
{
	public class ImportViewModel : ViewModel
	{
        public SelectList Agencies { get; set; }
        public IEnumerable<RadioButtonListItem> ImportTypes { get; private set; }
        public IEnumerable<RadioButtonListItem> ImportFormats { get; set; }

        [BindModel]
        public Model.Agency Agency { get; set; }

        [DisplayName(@"Import Type")]
        public ImportType ImportType { get; set; }

        [DisplayName(@"Import Format")]
        public ImportFormat ImportFormat { get; set; }

        public bool ShowClearDatabaseButton { get; set; }

        public ImportViewModel(IRepository repository, IPropertyRepository propertyRepository)
        {
            Agencies = new SelectList(repository.GetActiveForList<Model.Agency>(null), "Id", "Name");
            ImportTypes = (from i in EnumHelper.GetEnumerationItems<ImportType>()
                           select new RadioButtonListItem()
                           {
                               Value = i.Key,
                               Text = Regex.Replace(i.Value, "([a-z])([A-Z])", "$1 $2")
                           }).ToList();

            ImportFormats = (from i in EnumHelper.GetEnumerationItems<ImportFormat>()
                             select new RadioButtonListItem()
                             {
                                 Value = i.Key,
                                 Text = Regex.Replace(i.Value, "([a-z])([A-Z])", "$1 $2")
                             }).ToList();

        }
	}
}
