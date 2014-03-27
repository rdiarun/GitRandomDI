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
    public class AgencyGroupViewModel : ViewModel
    {

        public AgencyGroup AgencyGroup { get; private set; }

        public AgencyGroupViewModel(IRepository respository, int id)
        {
            if (id!=0)
			{
                AgencyGroup = respository.Get<AgencyGroup>(id);
			}
			else
			{
                AgencyGroup = new AgencyGroup();
			}

		}
    }
}
