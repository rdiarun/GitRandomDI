using System;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;

namespace DetectorInspector.Areas.Admin.ViewModels
{
	public class ServiceItemViewModel : ViewModel
	{
        public ServiceItem ServiceItem { get; private set; }
      
        public ServiceItemViewModel (IRepository repository)
        {
            ServiceItem = new ServiceItem();
        }

        public ServiceItemViewModel(IRepository repository, ServiceItem item) 
        {
            ServiceItem = item;
        }

	}
}
