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
    public class PropertyInfoSearchViewModel : ViewModel
    {
        public SelectList Agencies { get; private set; }
        public SelectList PropertyManagers { get; private set; }
        public SelectList ProblemSelectList { get; private set; }
        public SelectList CancelledSelectList { get; private set; }

        public IEnumerable<RadioButtonListItem> UpdateInspectionStatuses { get; private set; }
        public IEnumerable<RadioButtonListItem> UpdateElectricalWorkStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> DueForServiceInspectionStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> OnHoldInspectionStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> BookedInspectionStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> CompletedInspectionStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> SendForElectricalApprovalStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> AwaitingElectricalApprovalStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> ElectricalApprovalAcceptedStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> CompletedElectricalWorkStatuses { get; private set; }
        public IEnumerable<CheckBoxListItem> OnHoldElectricalWorkStatuses { get; private set; }

        public IEnumerable<RadioButtonListItem> BulkInspectionActionOptions { get; private set; }
        public IEnumerable<RadioButtonListItem> BulkElectricalWorkActionOptions { get; private set; }

        private IRepository _repository;

        public bool IsComingUpForService { get; set; }
        public bool DueForService { get; set; }
        public bool IsNew { get; set; }
        public bool IsOverDue { get; set; }
        public bool IsElectricianRequired { get; set; }
        public int? AgencyId { get; set; }
        public int? PropertyManagerId { get; set; }
        public bool? HasProblem { get; set; }
        public bool? Cancelled { get; set; }
        public string Keyword { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public IEnumerable<string> SelectedInspectionStatuses { get; set; }
        public IEnumerable<string> SelectedElectricalWorkStatuses { get; set; }

    

        public PropertyInfoSearchViewModel(IRepository repository, bool requireSelectLists, bool requireDefaults)
        {

            _repository = repository;

            if (requireDefaults)
            {
                SetDefaults();
            }

            if (requireSelectLists)
            {
                Initialize();
            }
        }

        private void SetDefaults()
        {

            SelectedInspectionStatuses = new List<string>();
            SelectedElectricalWorkStatuses = new List<string>();
        }

        private void Initialize()
        {
            var dueForService = new List<InspectionStatus>()
			{                
				InspectionStatus.RequireUpdatedDetails,
				InspectionStatus.BookViaMobilePhone,
				InspectionStatus.AwaitingUpdatedDetails,
				InspectionStatus.TenancyDetailsIncorrect,
				InspectionStatus.TenancyDetailsReceived,
				InspectionStatus.RequireContactUsLetter, 
				InspectionStatus.ContactUsLetterSent,
				InspectionStatus.RequireNotificationLetter
			};

            DueForServiceInspectionStatuses = (from p in dueForService
                                               select new CheckBoxListItem()
                                               {
                                                   Value = p.ToString("D"),
                                                   Text = p.GetDescription()
                                               }).ToList();

            var onHold = new List<InspectionStatus>()
			{
				InspectionStatus.PropertyOnHold
			};


            OnHoldInspectionStatuses = (from p in onHold
                                        select new CheckBoxListItem()
                                        {
                                            Value = p.ToString("D"),
                                            Text = p.GetDescription()
                                        }).ToList();

            var booked = new List<InspectionStatus>()
			{
				InspectionStatus.NotificationLetterSent,
				InspectionStatus.AppointmentBooked
			};

            BookedInspectionStatuses = (from p in booked
                                        select new CheckBoxListItem()
                                        {
                                            Value = p.ToString("D"),
                                            Text = p.GetDescription()
                                        }).ToList();

            var completed = new List<InspectionStatus>()
			{
				InspectionStatus.ReadyForInvoice
			};

            CompletedInspectionStatuses = (from p in completed
                                           select new CheckBoxListItem()
                                           {
                                               Value = p.ToString("D"),
                                               Text = p.GetDescription()
                                           }).ToList();

            var sendForElectricalApproval = new List<ElectricalWorkStatus>()
			{
				ElectricalWorkStatus.ElectricianRequired
			};

            SendForElectricalApprovalStatuses = (from p in sendForElectricalApproval
                                                 select new CheckBoxListItem()
                                                 {
                                                     Value = p.ToString("D"),
                                                     Text = p.GetDescription()
                                                 }).ToList();

            var awaitingElectricalApproval = new List<ElectricalWorkStatus>()
			{
				ElectricalWorkStatus.AwaitingElectricalApproval,
				ElectricalWorkStatus.PropertyOnHold
			};

            AwaitingElectricalApprovalStatuses = (from p in awaitingElectricalApproval
                                                  select new CheckBoxListItem()
                                                  {
                                                      Value = p.ToString("D"),
                                                      Text = p.GetDescription()
                                                  }).ToList();

            var onHoldElectrical = new List<ElectricalWorkStatus>()
			{
				ElectricalWorkStatus.PropertyOnHold
			};


            OnHoldElectricalWorkStatuses = (from p in onHoldElectrical
                                            select new CheckBoxListItem()
                                            {
                                                Value = p.ToString("D"),
                                                Text = p.GetDescription()
                                            }).ToList();

            var electricalApprovalAccepted = new List<ElectricalWorkStatus>()
			{
				ElectricalWorkStatus.ElectricalApprovalAccepted,
				ElectricalWorkStatus.ElectricalApprovalRejected,
				ElectricalWorkStatus.TenancyDetailsIncorrect,
				ElectricalWorkStatus.ContactDetailsSentToElectrician,
				ElectricalWorkStatus.AwaitingUpdatedDetails,
				ElectricalWorkStatus.RequireContactUsLetter,
				ElectricalWorkStatus.TenancyDetailsReceived,
				ElectricalWorkStatus.ContactUsLetterSent
			};

            ElectricalApprovalAcceptedStatuses = (from p in electricalApprovalAccepted
                                                  select new CheckBoxListItem()
                                                  {
                                                      Value = p.ToString("D"),
                                                      Text = p.GetDescription()
                                                  }).ToList();

            // everything selected by default
            SelectedInspectionStatuses = (from p in dueForService select p.ToString("D")).ToList();


            Agencies = new SelectList(_repository.GetActiveForList<DetectorInspector.Model.Agency>(null), "Id", "Name", AgencyId);
            if (AgencyId.HasValue)
            {
                var agency = _repository.Get<DetectorInspector.Model.Agency>(AgencyId.Value);
                PropertyManagers = new SelectList(agency.PropertyManagers, "Id", "Name", PropertyManagerId);
            }
            else
            {
                PropertyManagers = new SelectList(_repository.GetAllForList<DetectorInspector.Model.PropertyManager>(), "Id", "Name", PropertyManagerId);
            }

            var selectListItems = new List<SelectListItem>();
            var selectListItem = new SelectListItem();
            selectListItem.Selected = true;
            selectListItem.Text = "-- Any --";
            selectListItem.Value = string.Empty;
            selectListItems.Add(selectListItem);
            selectListItems.AddRange(SelectHtmlHelpers.GetYesNoSelectListItems());

            ProblemSelectList = new SelectList(selectListItems, "Value", "Text");

            CancelledSelectList = new SelectList(selectListItems, "Value", "Text", Boolean.FalseString);

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


            var updateElectricalWorkStatuses = new List<ElectricalWorkStatus>()
			{
				ElectricalWorkStatus.ElectricalApprovalAccepted,
				ElectricalWorkStatus.ElectricalApprovalRejected,
				ElectricalWorkStatus.TenancyDetailsIncorrect,
				ElectricalWorkStatus.RequireContactUsLetter,
				ElectricalWorkStatus.PropertyOnHold
			};


            UpdateElectricalWorkStatuses = (from p in updateElectricalWorkStatuses
                                            select new RadioButtonListItem()
                                               {
                                                   Value = p.ToString("D"),
                                                   Text = p.GetDescription()
                                               }).ToList();

            var bulkInspectionActionOptions = new List<BulkAction>()
			{
				BulkAction.GenerateNotificationLetter,
				BulkAction.GenerateContactUsLetter,                
				BulkAction.RequestForContactDetailsUpdate,    
				BulkAction.ExportForContactDetailsUpdate,
				BulkAction.ExportInspectionInvoice,
				BulkAction.GenerateEmailWithPropertyServiceHistory,
				BulkAction.CancelProperties,
				BulkAction.ApplyDiscount,
				BulkAction.UpdateInspectionStatus,
				BulkAction.ExportProperties,
				BulkAction.HoldProperties,
				BulkAction.CreateBulkList
			};

            BulkInspectionActionOptions = (from p in bulkInspectionActionOptions
                                           select new RadioButtonListItem()
                                           {
                                               Value = p.ToString("D"),
                                               Text = p.GetDescription()
                                           }).ToList();


            var bulkElectricalWorkActionOptions = new List<BulkAction>()
			{
				BulkAction.GenerateElectricalApprovalQuotation,
				BulkAction.GenerateElectricanJobReport,
				BulkAction.RequestForContactDetailsUpdate,
				BulkAction.ExportForContactDetailsUpdate,
				BulkAction.GenerateContactUsLetter,
				BulkAction.UpdateElectricalWorkStatus,
				BulkAction.HoldProperties
			};

            BulkElectricalWorkActionOptions = (from p in bulkElectricalWorkActionOptions
                                               select new RadioButtonListItem()
                                               {
                                                   Value = p.ToString("D"),
                                                   Text = p.GetDescription()
                                               }).ToList();
        }

        public IEnumerable<InspectionStatus> GetSelectedInspectionStatuses()
        {
            return (from i in SelectedInspectionStatuses
                    select (InspectionStatus)Enum.Parse(typeof(InspectionStatus), i));
        }

        public IEnumerable<ElectricalWorkStatus> GetSelectedElectricalWorkStatuses()
        {
            return (from i in SelectedElectricalWorkStatuses
                    select (ElectricalWorkStatus)Enum.Parse(typeof(ElectricalWorkStatus), i));
        }

        /// <summary>
        /// At least one search criterion must be provided
        /// </summary>
        /// <remarks>
        /// Ignore date range type 
        /// </remarks>
        /// <returns></returns>
        internal bool IsSufficientCriteriaToSearch()
        {

            return true;
        }

    }
}
