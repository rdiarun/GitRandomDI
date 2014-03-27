using System;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;

namespace DetectorInspector.Areas.Admin.ViewModels
{
	public class SuburbViewModel : ViewModel
	{
        public SelectList States { get; private set; }
        public SelectList Zones { get; private set; }
        public Suburb Suburb { get; private set; }
      
        public SuburbViewModel (IRepository repository)
        {
            Suburb = new Suburb();
            Suburb.State = new State();
            States = new SelectList(repository.GetAllForList<State>(), "Id", "Name", Suburb.State == null ? string.Empty : Suburb.State.Id.ToString());
            Zones = new SelectList(repository.GetAllForList<Zone>(), "Id", "Name", Suburb.Zone == null ? string.Empty : Suburb.Zone.Id.ToString());
        }

        public SuburbViewModel(IRepository repository, Suburb suburb) 
        {
            Suburb = suburb;
            States = new SelectList(repository.GetAllForList<State>(), "Id", "Name", Suburb.State == null ? string.Empty : Suburb.State.Id.ToString());
            Zones = new SelectList(repository.GetAllForList<Zone>(), "Id", "Name", Suburb.Zone == null ? string.Empty : Suburb.Zone.Id.ToString());
        }

	}
}
