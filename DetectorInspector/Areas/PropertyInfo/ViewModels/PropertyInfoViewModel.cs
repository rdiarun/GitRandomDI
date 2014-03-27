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
	public class PropertyInfoViewModel : ViewModel
	{
		public SelectList Agencies { get; private set; }
        public SelectList AgenciesNotPrivateLandlord { get; private set; }
		public SelectList JobTypes { get; private set; }
        public SelectList PrivateLandlordBillToTypes { get; private set; }
		public SelectList PropertyManagers { get; private set; }

        public SelectList PrivateLandlordPropertyManagers { get; private set; }

		public SelectList States { get; private set; }
		public SelectList LandlordStates { get; private set; }
		public SelectList PostalStates { get; private set; }
		public Model.PropertyInfo PropertyInfo { get; private set; }
		public IEnumerable<RadioButtonListItem> UpdateInspectionStatuses { get; private set; }

        private List<JobType> jobTypesList;
        private List<PrivateLandlordBillToType> privateLandlordBillToTypes;

        public enum PrivateLandlordBillToTypeEnum
        {
            BillToAgency = 1,
            BillToLandlord
        }

        public enum JobTypeTypeEnum
        {
            AgencyManaged = 1,
            PrivateLandlordWithAgency,
            PrivateLandlordNoAgency
        }


        public int PrivateLandlordsAgencyId
        {
            get
            {
                return _agencyRepository.GetPrivateLandlordsID();
            }

        }

        public String JobTypeNum
        {
            get
            {
                return PropertyInfo.JobType.ToString();

            }
        }

        public string JobTypeName
        {
            get
            {
                if (PropertyInfo.JobType==0)
                {
                    return "";
                }
                return jobTypesList[PropertyInfo.JobType-1].Name;
            }
        }
        public string PrivateLandlordBillToTypeName
        {
            get
            {
                if (PropertyInfo.PrivateLandlordBillTo == 0)
                {
                    return "";
                }
                return privateLandlordBillToTypes[PropertyInfo.PrivateLandlordBillTo-1].Name;
            }
        }


		public string FormattedPropertyNumber
		{
			get
			{
				if (null == PropertyInfo.Agency) return string.Empty;
				else
				{
					String prefix="";
#if false
/*
	rjc 20130415
	Jason said that the prefix needed to be added everywhere but Jordan now claims that this only needs to be added to one part of the invoice.
	Hence this code has been moved to the invoice generation code !
*/
					if (PropertyInfo.PropertyNumber > 999)
					{
						prefix += (char)((int)'A' - 1 + PropertyInfo.PropertyNumber / 1000);

						// 26 letters A - Z * 1000 properties per letter (prefix) + 1000 (first 1000 don't have a prefix) = 27000
						if (PropertyInfo.PropertyNumber >= 27000)
						{
							throw new ApplicationException("Property Number too large to create prefix letter");
						}
					}
#endif

					return String.Concat(PropertyInfo.Agency.CustomerCode, prefix, PropertyInfo.PropertyNumber);
				}

			}
		}
		private IRepository _repository;
		private IPropertyRepository _propertyRepository;
        private IAgencyRepository _agencyRepository;

		public bool IsCreate()
		{
			return PropertyInfo.IsDeleted.Equals(true);
		}

		public PropertyInfoViewModel(IRepository repository, IPropertyRepository propertyRepository, int id, bool requireSelectLists,IAgencyRepository agencyRepository)
		{
			_repository = repository;
			_propertyRepository = propertyRepository;
            _agencyRepository = agencyRepository;

			if (id!=0)
			{
				PropertyInfo = propertyRepository.Get(id);
			}
			else
			{
				PropertyInfo = new Model.PropertyInfo();
			}

			if (requireSelectLists)
			{
				Initialize();
			}


			var updateInspectionStatuses = new List<InspectionStatus>()
			{
				InspectionStatus.ReadyForService,
				InspectionStatus.RequireContactUsLetter,
				InspectionStatus.RequireNotificationLetter,
				InspectionStatus.BookViaMobilePhone,
				InspectionStatus.RequireUpdatedDetails,
				InspectionStatus.TenancyDetailsIncorrect
			};


			UpdateInspectionStatuses = (from p in updateInspectionStatuses
										select new RadioButtonListItem()
										{
											Value = p.ToString("D"),
											Text = p.GetDescription()
										}).ToList();

		}

		private void Initialize()
		{
			var states = _repository.GetAllForList<State>();
			int defaultStateId = ApplicationConfig.Current.DefaultStateId;
			int? stateId = null;


			if (PropertyInfo.State != null)
			{
				stateId = PropertyInfo.State.Id;
			}

			States = new SelectList(states, "Id", "Name", PropertyInfo.Id != 0 ? stateId : defaultStateId);

			int? landlordStateId = null;


			if (PropertyInfo.LandlordState != null)
			{
				landlordStateId = PropertyInfo.LandlordState.Id;
			}

			LandlordStates = new SelectList(states, "Id", "Name", PropertyInfo.Id != 0 ? landlordStateId : defaultStateId);

			int? postalStateId = null;


			if (PropertyInfo.PostalState != null)
			{
				postalStateId = PropertyInfo.PostalState.Id;
			}

			PostalStates = new SelectList(states, "Id", "Name", PropertyInfo.Id != 0 ? postalStateId : defaultStateId);

			int? agencyId = null;
			if (PropertyInfo.Agency != null)
			{
				agencyId = PropertyInfo.Agency.Id;
			}

			Agencies = new SelectList(_repository.GetActiveForList<Model.Agency>(agencyId), "Id", "Name", agencyId.HasValue ? agencyId.ToString() : string.Empty);

            AgenciesNotPrivateLandlord = new SelectList(_repository.GetActiveForList<Model.Agency>(agencyId).Where(e => e.IsPrivateLandlord == false), "Id", "Name", agencyId.HasValue ? agencyId.ToString() : string.Empty);


           // SelectList privateLandLordAgencies = Agencies.Items.Cast<IEnumerable<Model.Agency>>().Where(e => e.IsCancelled == 0);
            
            PropertyManagers = new SelectList(new List<PropertyManager>(), string.Empty);
			int? propertyManagerId = null;
			if (PropertyInfo.Agency != null)
			{
				if (PropertyInfo.PropertyManager != null)
				{
					propertyManagerId = PropertyInfo.PropertyManager.Id;
				}
				else
				{
					if (PropertyInfo.Agency.DefaultPropertyManager != null)
					{
						propertyManagerId = PropertyInfo.Agency.DefaultPropertyManager.Id;
					}
				}
				PropertyManagers = new SelectList(PropertyInfo.Agency.ActivePropertyManagers, "Id", "Name", propertyManagerId.HasValue ? propertyManagerId.ToString() : string.Empty);
			}



            PrivateLandlordPropertyManagers = new SelectList(new List<PropertyManager>(), string.Empty);
            
            if (PropertyInfo.PrivateLandlordAgency != null)
            {
                if (PropertyInfo.PrivateLandlordPropertyManager != null)
                {
                    propertyManagerId = PropertyInfo.PrivateLandlordPropertyManager.Id;
                }
                else
                {
                    if (PropertyInfo.PrivateLandlordAgency.DefaultPropertyManager != null)
                    {
                        propertyManagerId = PropertyInfo.PrivateLandlordAgency.DefaultPropertyManager.Id;
                    }
                }
                PrivateLandlordPropertyManagers = new SelectList(PropertyInfo.PrivateLandlordAgency.ActivePropertyManagers, "Id", "Name", propertyManagerId.HasValue ? propertyManagerId.ToString() : string.Empty);
            }


            jobTypesList = new List<JobType>();
            jobTypesList.Add( new JobType((int)JobTypeTypeEnum.AgencyManaged , "Agency Managed"));
            jobTypesList.Add(new JobType((int)JobTypeTypeEnum.PrivateLandlordWithAgency, "Private Landlord with agency"));
            jobTypesList.Add(new JobType((int)JobTypeTypeEnum.PrivateLandlordNoAgency, "Private Landlord no agency"));
            JobTypes = new SelectList(jobTypesList, "Id", "Name");            //_repository.GetActiveForList<Model.Agency>(agencyId), "Id", "Name", agencyId.HasValue ? agencyId.ToString() : string.Empty);

            privateLandlordBillToTypes = new List<PrivateLandlordBillToType>();
            privateLandlordBillToTypes.Add(new PrivateLandlordBillToType((int)PrivateLandlordBillToTypeEnum.BillToAgency, "Agency"));
            privateLandlordBillToTypes.Add(new PrivateLandlordBillToType((int)PrivateLandlordBillToTypeEnum.BillToLandlord, "Landlord"));
            PrivateLandlordBillToTypes = new SelectList(privateLandlordBillToTypes, "Id", "Name"); 
		}
		

		public void UpdateModel(bool hasChangedAgency,bool hasCancelledChanged=false)
		{
			// Changed to ensure IsDeleted Bit is set correctly when creating/edting properties.

			//if (PropertyInfo.PropertyNumber == 0)
			//{
			//    PropertyInfo.IsDeleted = false;
			//    PropertyInfo.PropertyNumber = _propertyRepository.GetPropertyNumber(PropertyInfo.Agency.Id);
			//}

			
			PropertyInfo.IsDeleted = false;

			if (PropertyInfo.PropertyNumber <= 0 || hasChangedAgency)
			{
				PropertyInfo.PropertyNumber = _propertyRepository.GetPropertyNumber(PropertyInfo.Agency.Id);
			}

			if (PropertyInfo.SettlementDate > DateTime.Today)
			{
				PropertyInfo.PropertyHoldDate = PropertyInfo.SettlementDate;
				PropertyInfo.InspectionStatus = InspectionStatus.PropertyOnHold;
				PropertyInfo.InspectionStatusUpdatedDate = DateTime.UtcNow;
				PropertyInfo.ContactNotes = string.Concat(string.Format("Settled {0} ", StringFormatter.LocalDate(PropertyInfo.SettlementDate)), PropertyInfo.ContactNotes);
			}

			if (PropertyInfo.IsCancelled)
			{
				PropertyInfo.Cancel();
			}

            if (hasCancelledChanged && PropertyInfo.IsReactivated==true)
            {
                // need to re-actiavte
                PropertyInfo.Reactivate();
            }
		}
		
	}
    class JobType
    {
        public virtual int Id { get; set; }
        public virtual string Name { get; set; }
        public JobType(int id, string name)
        {
            Id = id;
            Name = name;
        }
    }

    

    class PrivateLandlordBillToType
    {
        public virtual int Id { get; set; }
        public virtual string Name { get; set; }
        public PrivateLandlordBillToType(int id, string name)
        {
            Id = id;
            Name = name;
        }
    }



}
