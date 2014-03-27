using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;
using System.IO;

namespace DetectorInspector.Areas.Agency.ViewModels
{
	public class AgencyViewModel : ViewModel
	{
		public SelectList AgencyGroups { get; private set; }
		public SelectList StreetStates { get; private set; }
		public SelectList PostalStates { get; private set; }
		public SelectList PropertyManagers { get; private set; }
		public SelectList ClientDatabaseSystemTypes { get; private set; }

		public DetectorInspector.Model.Agency Agency { get; private set; }
		public Boolean HasEntryNotificationLetter
		{
			get
			{

				string savedFileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EntryNotificationLetterTemplates");
				savedFileName = Path.Combine(savedFileName, this.Agency.Id.ToString() + ".docx");
				return File.Exists(savedFileName);

			}
			private set
			{
				// Do nothing
			}
		}

		public bool IsCreate()
		{
			return Agency.Id == 0;
		}

		public AgencyViewModel(IRepository repository, IAgencyRepository agencyRepository, int id)
		{
			if (id!=0)
			{
				Agency = agencyRepository.Get(id);
			}
			else
			{
				Agency = new DetectorInspector.Model.Agency();
			}
			int? agencyGroupId = null;
			if (Agency.AgencyGroup != null)
			{
				agencyGroupId = Agency.AgencyGroup.Id;
			}

			AgencyGroups = new SelectList(repository.GetActiveForList<AgencyGroup>(agencyGroupId), "Id", "Name", agencyGroupId.HasValue ? agencyGroupId.ToString() : string.Empty);

			var states = repository.GetAllForList<State>();
			var clientDatabaseSystems = repository.GetAllForList<ClientDatabaseSystem>();
			int defaultStateId = ApplicationConfig.Current.DefaultStateId;
			int defaultClientSystemId = 1;
			int? streetStateId = null;
			int? postalStateId = null;
			int? ClientDatabaseSystemTypeId = null;


			if (Agency.StreetState != null)
			{
				streetStateId = Agency.StreetState.Id;
			}

			if (Agency.PostalState != null)
			{
				postalStateId = Agency.PostalState.Id;
			}


			StreetStates = new SelectList(states, "Id", "Name", id != 0 ? streetStateId : defaultStateId);
			PostalStates = new SelectList(states, "Id", "Name", id != 0 ? postalStateId : defaultStateId);


			if (Agency.ClientDatabaseSystemType != null)
			{
				ClientDatabaseSystemTypeId = Agency.ClientDatabaseSystemType.Id;
			}

			ClientDatabaseSystemTypes = new SelectList(clientDatabaseSystems, "Id", "Name", id != 0 ? ClientDatabaseSystemTypeId : defaultClientSystemId);

			int? defaultPropertyManagerId = null;
			if (Agency.DefaultPropertyManager != null)
			{
				defaultPropertyManagerId = Agency.DefaultPropertyManager.Id;
			}

			PropertyManagers = new SelectList(Agency.ActivePropertyManagers, "Id", "Name", defaultPropertyManagerId.HasValue ? defaultPropertyManagerId.ToString() : string.Empty);

		}
	}
}
