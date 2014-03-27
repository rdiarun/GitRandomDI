using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.ServiceSheet.ViewModels
{
    public class ServiceSheetItemViewModel : ViewModel
    {

        public ServiceSheetItem ServiceSheetItem { get; private set; }
        public DetectorInspector.Model.ServiceSheet ServiceSheet { get; private set; }

        public SelectList DetectorTypes { get; private set; }
        
        
        public bool IsCreate()
        {
            return ServiceSheetItem.Id == 0;
        }

        public ServiceSheetItemViewModel(IRepository repository, DetectorInspector.Model.ServiceSheet serviceSheet, int id)
        {
            ServiceSheet = serviceSheet;
            var detector = new Detector(serviceSheet.Booking.PropertyInfo);
            if (id!=0)
			{
                ServiceSheetItem = repository.Get<ServiceSheetItem>(id);
			}
			else
			{
                ServiceSheetItem = new ServiceSheetItem(serviceSheet, detector);
			}


            int? detectorTypeId = null;


            if (ServiceSheetItem.DetectorType != null)
            {
                detectorTypeId = ServiceSheetItem.DetectorType.Id;
            }


            DetectorTypes = new SelectList(repository.GetAllForList<DetectorType>(), "Id", "Name");


		}
    }
}
