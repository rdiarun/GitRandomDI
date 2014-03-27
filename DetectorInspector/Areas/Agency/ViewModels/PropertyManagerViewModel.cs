using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.Agency.ViewModels
{
    public class PropertyManagerViewModel : ViewModel
    {

        public DetectorInspector.Model.Agency Agency { get; private set; }
        public PropertyManager PropertyManager { get; private set; }

        public bool IsCreate()
        {
            return PropertyManager.Id == 0;
        }

        public PropertyManagerViewModel(IRepository repository, DetectorInspector.Model.Agency agency, int id)
        {
            Agency = agency;
            if (id!=0)
			{
                PropertyManager = repository.Get<PropertyManager>(id);
			}
			else
			{
                PropertyManager = new PropertyManager(Agency);
			}
		}
    }
}
