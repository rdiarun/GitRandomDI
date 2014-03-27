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
    public class DetectorViewModel : ViewModel
    {

        public DetectorInspector.Model.PropertyInfo PropertyInfo { get; private set; }
        public Detector Detector { get; private set; }
        public SelectList DetectorTypes { get; private set; }

        public bool IsCreate()
        {
            return Detector.Id == 0;
        }

        public DetectorViewModel(IRepository repository, DetectorInspector.Model.PropertyInfo propertyInfo, int id)
        {
            PropertyInfo = propertyInfo;
            if (id!=0)
			{
                Detector = repository.Get<Detector>(id);
			}
			else
			{
                Detector = new Detector(propertyInfo);
			}

            int? detectorTypeId = null;


            if (Detector.DetectorType != null)
            {
                detectorTypeId = Detector.DetectorType.Id;
            }


            DetectorTypes = new SelectList(repository.GetAllForList<DetectorType>(), "Id", "Name");

		}
    }
}
