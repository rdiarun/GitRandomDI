using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.PropertyInfo.ViewModels
{
    public class BulkActionViewModel : ViewModel
    {
        public BulkAction bulkAction { get; set; }
        public IEnumerable<int> selectedRows { get; set; }
        public DateTime? notificationDate { get; set; }

        public BulkActionViewModel()
        {
            selectedRows = new List<int>();
		}

    }
}
