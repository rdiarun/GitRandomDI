using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using System.Net.Mail;
using DetectorInspector.Areas.PropertyInfo.ViewModels;
using DetectorInspector.Common.Formatters;
using DetectorInspector.Common.Notifications;
using DetectorInspector.Controllers;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Infrastructure.QuickBooks;
using DetectorInspector.Model;
using Kiandra.Data;
using Kiandra.Web.Mvc;


using System.Diagnostics;

using DetectorInspector;
using Ionic.Zip;

using System.Data.SqlClient;
using System.Configuration;
using System.Collections;

namespace DetectorInspector.Areas.PropertyInfo.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AccessProperties)]
    public class HomeController : SiteController
    {
        private readonly IPropertyRepository _propertyRepository;
        private readonly INotificationService _notificationService;

        private readonly IBookingRepository _bookingRepository;
        private readonly IAgencyRepository _agencyRepository;
        private string Propertydetails;
        // private string PropertydetailMessage;
        public HomeController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IPropertyRepository propertyRepository,
            INotificationService notificationService,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository,
            IBookingRepository bookingRepository, IAgencyRepository agencyRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _propertyRepository = propertyRepository;
            _notificationService = notificationService;
            _bookingRepository = bookingRepository;
            _agencyRepository = agencyRepository;


        }

        [HttpGet]
        public ActionResult Index()
        {
            if (User.Identity.IsAuthenticated == false)
            {
                return RedirectToAction("Index", "Home", new { area = "" });
            }
            var model = new PropertyInfoSearchViewModel(Repository, true, true);

            return View(model);
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetItems(string sortBy, string sortDirection, int pageNumber, int pageSize, FormCollection form)
        {
            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var model = new PropertyInfoSearchViewModel(Repository, false, true);

            if (TryUpdateModel(model, form.ToValueProvider()))
            {
                if (model.IsSufficientCriteriaToSearch())
                {
                    int itemCount;
                    int pageCount;
                    var items = _propertyRepository.Search(model.IsComingUpForService,
                        model.DueForService,
                        model.IsNew,
                        model.IsOverDue,
                        model.IsElectricianRequired,
                        model.AgencyId,
                        model.PropertyManagerId,
                        model.HasProblem,
                        model.Cancelled,
                        model.GetSelectedInspectionStatuses(),
                        model.GetSelectedElectricalWorkStatuses(),
                        model.Keyword,
                        model.StartDate,
                        model.EndDate,
                        pageNumber, pageSize, sortBy, listSortDirection, false, out itemCount, out pageCount);

                    /* rjc debug slow code
                     var stopWatch = new Stopwatch();
                    stopWatch.Start();
                     */


                    var result = new
                    {
                        pageCount = pageCount,
                        pageNumber = pageNumber,
                        itemCount = itemCount,
                        items = (
                            from item in items
                            select new
                            {
                                id = item.Id,
                                propertyNumber = item.PropertyNumber == null ? string.Empty : item.PropertyNumber.ToString(),
                                unitShopNumber = HttpUtility.HtmlEncode(item.UnitShopNumber != null ? item.UnitShopNumber : string.Empty),
                                streetNumber = HttpUtility.HtmlEncode(item.StreetNumber ?? string.Empty),
                                streetName = HttpUtility.HtmlEncode(item.StreetName ?? string.Empty),
                                state = HttpUtility.HtmlEncode(item.State ?? string.Empty),
                                suburb = HttpUtility.HtmlEncode(item.Suburb ?? string.Empty),
                                postCode = HttpUtility.HtmlEncode(item.PostCode != null ? item.PostCode : string.Empty),
                                inspectionStatusEnum = HttpUtility.HtmlEncode(item.InspectionStatusEnum.ToString()),
                                inspectionStatus = string.Format("<div class=\"inspection-{0}\">{1}</div>", FormatInspectionStatus(item).ToLower(), FormatInspectionStatusDisplayText(item)),
                                electricalWorkStatusEnum = HttpUtility.HtmlEncode(item.ElectricalWorkStatusEnum.ToString()),
                                electricalWorkStatus = string.Format("<div class=\"electrical-work-{0}\">{1}</div>", FormatElectricalWorkStatus(item).ToLower(), GetDynamicElectricalWorkStatus(item)),
                                agencyName = HttpUtility.HtmlEncode(item.AgencyName != null ? item.AgencyName : string.Empty),
                                propertyManager = HttpUtility.HtmlEncode(item.PropertyManager != null ? item.PropertyManager : string.Empty),
                                contactNotes = HttpUtility.HtmlEncode(item.ContactNotes ?? string.Empty),
                                keyNumber = HttpUtility.HtmlEncode(item.KeyNumber != null ? item.KeyNumber : string.Empty),
                                tenantName = HttpUtility.HtmlEncode(item.TenantName != null ? item.TenantName : string.Empty),
                                tenantContactNumber = HttpUtility.HtmlEncode(item.TenantContactNumber != null ? item.TenantContactNumber : string.Empty),
                                lastServicedDate = item.LastServicedDate == null ? string.Empty : StringFormatter.LocalDate(item.LastServicedDate.Value),
                                nextServiceDate = string.Format("<div class=\"due-{0}\">{1}</div>", DueDateFormatter.FormatNextDueDate(item).ToLower(), item.NextServiceDate == null ? string.Empty : StringFormatter.LocalDate(item.NextServiceDate.Value)),
                                bookingDate = item.BookingDate == null ? string.Empty : StringFormatter.LocalDate(item.BookingDate.Value),
                                hasProblem = StringFormatter.BooleanToYesNo(item.HasProblem),
                                hasLargeLadder = StringFormatter.BooleanToYesNo(item.HasLargeLadder),
                                isNew = StringFormatter.BooleanToYesNo(item.IsNew),
                                isOverDue = StringFormatter.BooleanToYesNo(item.IsOverDue),
                                isElectricianRequired = StringFormatter.BooleanToYesNo(item.IsElectricianRequired),
                                isCancelled = item.IsCancelled,
                                rowVersion = Convert.ToBase64String(item.RowVersion),
                                selectLink = string.Format("<input type=\"checkbox\" name=\"selectedRow\" value=\"{0}\" onClick=\"var count = getPropertyCount();updatePropertyCounter(count);\">", item.Id),
                                editLink = string.Format("<a href=\"#\" onclick=\"openPropertyInfo('{0}');return false;\" class=\"button-edit\">View</a>", item.Id),
                                notesLink = string.Format("<a href=\"#\" onclick=\"showContactNotes('{0}', ' + escape({1}) + ', '{2}'); return false;\" class=\"button-notes\">Notes</a>", item.Id, HttpUtility.HtmlEncode(item.ToString()), Convert.ToBase64String(item.RowVersion))
                            })
                    };

                    /* rjc debug slow code
                    var jsonResult = Json(result);
                    stopWatch.Stop();
                    var executionTime = stopWatch.Elapsed;
                     */

                    return Json(result);
                }
                else
                {
                    return Json(string.Empty);
                }
            }

            return Json(string.Empty);
        }

        private string FormatInspectionStatusDisplayText(PropertyInfoSearchResult item)
        {
            if (item.IsCancelled)
            {
                return "Cancelled";
            }
            else if (item.HasProblem)
            {
                return string.Format("{0} (Problem)", item.InspectionStatus);
            }

            return item.InspectionStatus;
        }

        private string FormatInspectionStatus(PropertyInfoSearchResult item)
        {
            return item.IsCancelled ? "Cancelled" : Enum.Parse(typeof(InspectionStatus), item.InspectionStatusEnum.ToString()).ToString();
        }

        private string FormatElectricalWorkStatus(PropertyInfoSearchResult item)
        {
            var status = Enum.Parse(typeof(ElectricalWorkStatus), item.ElectricalWorkStatusEnum.ToString()).ToString();

            if ((item.ElectricalWorkStatusEnum == (int)ElectricalWorkStatus.NoElectricianRequired || item.ElectricalWorkStatusEnum == (int)ElectricalWorkStatus.ElectricianRequired) && item.IsElectricianRequired)
                status = "ElectricianRequired";

            return status;
        }

        private string GetDynamicElectricalWorkStatus(PropertyInfoSearchResult item)
        {
            var statusText = item.ElectricalWorkStatus;

            if ((item.ElectricalWorkStatusEnum == (int)ElectricalWorkStatus.NoElectricianRequired || item.ElectricalWorkStatusEnum == (int)ElectricalWorkStatus.ElectricianRequired) && item.IsElectricianRequired)
                statusText = "Electrician Required (Automatic)";

            return statusText;
        }


        [HttpPost]
        [Transactional]
        public ActionResult GetHasProblemCount(int? agencyId, int? propertyManagerId, DateTime? startDate, DateTime? endDate, bool? hasProblem, string keyword)
        {
            var items = _propertyRepository.GetHasProblemCount(agencyId, propertyManagerId, startDate, endDate, hasProblem, keyword).ToArray();
            return Json(items);
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetInspectionStatusCount(int? agencyId, int? propertyManagerId, DateTime? startDate, DateTime? endDate, bool? hasProblem, string keyword)
        {
            var items = _propertyRepository.GetInspectionStatusCount(agencyId, propertyManagerId, startDate, endDate, hasProblem, keyword).ToArray();
            var jsonData = Json(items);
            return jsonData;
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetElectricalWorkStatusCount(int? agencyId, int? propertyManagerId, DateTime? startDate, DateTime? endDate, bool? hasProblem, string keyword)
        {
            var items = _propertyRepository.GetElectricalWorkStatusCount(agencyId, propertyManagerId, startDate, endDate, hasProblem, keyword).ToArray();
            var jsonData = Json(items);
            return jsonData;
        }

        private void AddApprovedOrRejectedLogItem(int propertyID, FormCollection theForm, string attachmentGid, string mimeType, bool isApproved)
        {
            DetectorInspector.Model.PropertyInfo pInfo = _propertyRepository.Get(propertyID);

            using (var tx = TransactionFactory.BeginTransaction())
            {
                ChangeLogTypeUpdateElectricalWorkStatus_ElectricalApproval itemDetails = new ChangeLogTypeUpdateElectricalWorkStatus_ElectricalApproval();

                ChangeLog newCl = new ChangeLog(pInfo, isApproved == true ? ChangeLogItemType.UpdateElectricalWorkStatus_ElectricalApprovalAccepted : ChangeLogItemType.UpdateElectricalWorkStatus_ElectricalApprovalRejected);


                string s = theForm["electricalWorkApprovalEmailTo"];
                string s2 = HttpUtility.UrlDecode(s);


                itemDetails.communicationType = theForm["approvalCommunicationType"];
                if (itemDetails.communicationType == "email")
                {
                    itemDetails.isEmail = true;
                    itemDetails.isFax = false;
                    itemDetails.EmailTo = HttpUtility.UrlDecode(theForm["electricalWorkApprovalEmailTo"]);
                    itemDetails.EmailFrom = HttpUtility.UrlDecode(theForm["electricalWorkApprovalEmailFrom"]);
                    itemDetails.EmailDateTime = HttpUtility.UrlDecode(theForm["electricalWorkApprovalEmailDateTime"]);
                }

                if (itemDetails.communicationType == "fax")
                {
                    itemDetails.isEmail = false;
                    itemDetails.isFax = true;
                    itemDetails.TimeRecieved = HttpUtility.UrlDecode(theForm["electricalWorkApprovalTimeReceived"]);
                    itemDetails.DateRecieved = HttpUtility.UrlDecode(theForm["electricalWorkApprovalDateReceived"]);
                }

                itemDetails.Subject = HttpUtility.UrlDecode(theForm["electricalWorkApprovalSubject"]);
                itemDetails.Message = HttpUtility.UrlDecode(theForm["electricalWorkApprovalMessage"]);
                newCl.encodeDataDetails((Object)itemDetails);


                if (attachmentGid != null)
                {
                    newCl.AttachmentUID = attachmentGid;
                    newCl.AttachmentDocName = theForm["attachmentFileName"];

                    newCl.AttachmentDocType = mimeType;
                }

                pInfo.AddChangeLogEntry(newCl);

                Repository.Save(newCl);
                Repository.Save(pInfo);

                try
                {
                    tx.Commit();
                }
                catch (DataCurrencyException)
                {
                    ShowErrorMessage("Save Failed", string.Format(SR.DataCurrencyException_Edit_Message, "ChangeLog Entry"));
                }
            }
        }

        [HttpPost]
        public ActionResult PerformBulkAction(BulkAction bulkAction, IEnumerable<int> selectedRows, InspectionStatus? inspectionStatus, ElectricalWorkStatus? electricalWorkStatus, decimal? discount, string notes, DateTime? notificationDate, FormCollection form)
        {

            var model = new BulkActionViewModel();
            var userProfile = User.Identity.GetProfile();

            if (bulkAction.Equals(BulkAction.ExportMobileNumberForSMS))
            {
                if (TryUpdateModel(model, form.ToValueProvider()))
                {
                    return ExportMobileNumberForSMS(model.notificationDate.Value);
                }
            }
            if (selectedRows == null)
            {
                return Json(new { success = false, message = "No rows selected" });
            }

            switch (bulkAction)
            {
                case BulkAction.ApplyDiscount:
                    if (!discount.HasValue)
                    {
                        return Json(new { success = false, message = "No discount supplied." });
                    }
                    _propertyRepository.UpdateDiscount(selectedRows, discount.Value, User.Identity.GetUserId().Value);
                    break;

                case BulkAction.CancelProperties:
                    _propertyRepository.Cancel(selectedRows, notes, User.Identity.GetUserId().Value);
                    break;

                case BulkAction.UpdateInspectionStatus:
                    if (!inspectionStatus.HasValue)
                    {
                        return Json(new { success = false, message = "No Inspection Status selected" });
                    }
                    _propertyRepository.UpdateInspectionStatus(selectedRows, inspectionStatus.Value, User.Identity.GetUserId().Value);
                    break;

                case BulkAction.UpdateElectricalWorkStatus:
                    if (!electricalWorkStatus.HasValue)
                    {
                        return Json(new { success = false, message = "No Electrical Work Status selected" });
                    }

                    if (electricalWorkStatus.Value.Equals(ElectricalWorkStatus.ElectricalApprovalRejected))
                    {
                        _propertyRepository.UpdateElectricalWorkStatus(selectedRows, electricalWorkStatus.Value, User.Identity.GetUserId().Value);
                        _propertyRepository.UpdateInspectionStatus(selectedRows, InspectionStatus.ReadyForInvoice, User.Identity.GetUserId().Value);
                    }

                    if (electricalWorkStatus.Value.Equals(ElectricalWorkStatus.ElectricalApprovalAccepted) || electricalWorkStatus.Value.Equals(ElectricalWorkStatus.ElectricalApprovalRejected))
                    {
                        if (form["approvalCommunicationType"] == "none" && form["attachmentData"] == "")
                        {
                            return Json(new { success = false, message = "You must attach a file if the approval is not an Email or a Fax" });
                        }

                        if (form["approvalCommunicationType"] == "email" && (form["electricalWorkApprovalEmailTo"] == "" || form["electricalWorkApprovalEmailFrom"] == "" || form["electricalWorkApprovalEmailDateTime"] == ""))
                        {
                            return Json(new { success = false, message = "You must specify - From, To and Sent Date/Time of the Email" });
                        }

                        if (form["approvalCommunicationType"] == "fax" && (form["electricalWorkApprovalTimeReceived"] == "" || form["electricalWorkApprovalDateReceived"] == ""))
                        {
                            return Json(new { success = false, message = "You must specify - the Date and Time of the Fax" });
                        }

                        _propertyRepository.UpdateElectricalWorkStatus(selectedRows, electricalWorkStatus.Value, User.Identity.GetUserId().Value);

                        string documentGuid = null;
                        string mimeType = "";

                        if (form["attachmentData"] != "")
                        {
                            string jsonFileData = form["attachmentData"];
                            string headerData = jsonFileData.Substring(0, jsonFileData.IndexOf(','));
                            mimeType = headerData.Split(';')[0].Split(':')[1];

                            // if Browser can't associate the file with a type, i.e Chrome we need to just default it (like firefox does)
                            if (mimeType == null || mimeType == "")
                            {
                                mimeType = "application/octet-stream";
                            }

                            int dataStart = jsonFileData.IndexOf(',') + 1;

                            string base64Data = jsonFileData.Substring(dataStart);

                            byte[] decodedBytes = Convert.FromBase64String(base64Data);


                            documentGuid = System.Guid.NewGuid().ToString();
                            string savedFileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "LinkedDatabaseContent/LogItems");
                            //savedFileName = Path.Combine(savedFileName, documentGuid);
                            try
                            {
                             //  	System.IO.File.WriteAllBytes(savedFileName, decodedBytes);

                            }
                            catch
                            {
                                return Json(new { success = false, message = "Error saving approval file" });
                            }
                        }

                        bool isApproved = false;

                        if (electricalWorkStatus.Value.Equals(ElectricalWorkStatus.ElectricalApprovalAccepted))
                        {
                            isApproved = true;
                        }

                        foreach (int selectedRow in selectedRows)
                        {
                            AddApprovedOrRejectedLogItem(selectedRow, form, documentGuid, mimeType, isApproved);
                        }


                    }
                    break;
                //case BulkAction.ExportInspectionInvoice:
                //    if (TryUpdateModel(model, form.ToValueProvider()))
                //    {
                //        _propertyRepository.UpdateInspectionStatus(model.selectedRows, inspectionStatus.Value, User.Identity.GetUserId().Value);
                //        var propertyBatch = new PropertyBatch();
                //        using (var tx = TransactionFactory.BeginTransaction("Create Inspection Invoice"))
                //        {
                //            propertyBatch.BulkActionId = (int)BulkAction.ExportInspectionInvoice;
                //            propertyBatch.StatusId = (int)inspectionStatus.Value;
                //            propertyBatch.Date = model.notificationDate.Value;
                //            foreach (var rowId in selectedRows)
                //            {
                //                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                //            }
                //            Repository.Save(propertyBatch);
                //            tx.Commit();
                //        }
                //        return ExportInspectionInvoice(propertyBatch);
                //  FileStreamResult s = ExportInspectionInvoice(propertyBatch, ref c);
                //  return Json.ToString();
                //  return Json(new { success = c, message = "No Inspection Status selected" });

                //  return Json(new { success = true, message = "No rows selected" });
                //}
                //break;     
                case BulkAction.ExportProperties:
                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        return ExportProperties(model.selectedRows);
                    }
                    break;

                case BulkAction.GenerateNotificationLetter:

                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        var filteredRows = new List<int>();
                        var selectedProperties = _propertyRepository.GetSelectedProperties(model.selectedRows);
                        foreach (var property in selectedProperties)
                        {
                            if (property.HasSendNotification)
                            {
                                filteredRows.Add(property.Id);
                            }
                        }

                        if (filteredRows.Count < 1)
                        {
                            return Json(new { success = false, message = "No rows selected" });
                        }


                        var preCheckProperyBatch = new PropertyBatch();
                        preCheckProperyBatch.Date = model.notificationDate.Value;
                        foreach (var rowId in selectedRows)
                        {
                            preCheckProperyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                        }

                        int? agencyID = null;
                        // Check batch is OK.
                        foreach (Model.PropertyInfo item in preCheckProperyBatch.PropertyInfo)
                        {
                            if (item.Agency.UseEntryNotificationLetter != true)
                            {
                                return File(new MemoryStream(UTF8Encoding.Default.GetBytes("<html><body><h1>ERROR</h1><p>The agency for these properties doesn't allow an entry notification letter to be sent.</p></body></html>")), "application/msword", "Error.doc");

                            }
                            if (agencyID == null)
                            {
                                agencyID = item.Agency.Id;
                            }
                            else
                            {
                                if (agencyID != item.Agency.Id)
                                {
                                    return File(new MemoryStream(UTF8Encoding.Default.GetBytes("<html><body><h1>ERROR</h1><p>The batch selected contains more than one agency</p></body></html>")), "application/msword", "Error.doc");
                                }
                            }
                        }
                        // check agency has template doc file     
                        string templateDoc = ApplicationConfig.Current.SystemBasePath + "\\EntryNotificationLetterTemplates\\" + agencyID.ToString() + ".docx";
                        if (!System.IO.File.Exists(templateDoc))
                        {
                            return File(new MemoryStream(UTF8Encoding.Default.GetBytes("<html><body><h1>ERROR</h1><p>No word doc template for Agency</p></body></html>")), "application/msword", "Error.doc");
                        }
                        _propertyRepository.UpdateInspectionStatus(model.selectedRows, InspectionStatus.NotificationLetterSent, User.Identity.GetUserId().Value);
                        var bookings = _propertyRepository.CreateBookings(model.selectedRows, model.notificationDate.Value);
                        var propertyBatch = new PropertyBatch();
                        using (var tx = TransactionFactory.BeginTransaction("Create Booking"))
                        {
                            propertyBatch.BulkActionId = (int)BulkAction.GenerateNotificationLetter;
                            propertyBatch.StatusId = (int)InspectionStatus.NotificationLetterSent;
                            propertyBatch.Date = model.notificationDate.Value;

                            foreach (var booking in bookings)
                            {
                                Repository.Save(booking);
                            }
                            propertyBatch.Date = model.notificationDate.Value;
                            foreach (var rowId in selectedRows)
                            {
                                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                            }
                            Repository.Save(propertyBatch);
                            tx.Commit();
                        }
                        return GenerateNotificationLetter(propertyBatch.Id, model, templateDoc);
                    }
                    break;

                case BulkAction.GenerateElectricalApprovalQuotation:

                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        //   _propertyRepository.UpdateElectricalWorkStatus(model.selectedRows, ElectricalWorkStatus.AwaitingElectricalApproval, User.Identity.GetUserId().Value);
                        var propertyBatch = new PropertyBatch();
                        using (var tx = TransactionFactory.BeginTransaction("Create Electrical Approval Quotation"))
                        {
                            propertyBatch.BulkActionId = (int)BulkAction.GenerateElectricalApprovalQuotation;
                            propertyBatch.StatusId = (int)ElectricalWorkStatus.AwaitingElectricalApproval;
                            propertyBatch.Date = DateTime.Today;
                            foreach (var rowId in selectedRows)
                            {
                                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                            }
                            Repository.Save(propertyBatch);
                            //   Change  by Arun 24 Feb 2014   Electricak Automatic
                            //   tx.Commit();
                            try
                            {
                                //   Change  by Arun 24 Feb 2014   Electricak Automatic
                                // return GenerateElectricalApprovalQuotation(propertyBatch.Id);
                                return GenerateElectricalApprovalQuotation(propertyBatch);
                            }
                            catch (DetectorInspectorInvalidDataException de)
                            {

                                MemoryStream stream = new MemoryStream();
                                StreamWriter writer = new StreamWriter(stream);
                                writer.Write("Unable to process batch:\n\r" + de.getDescription());
                                writer.Flush();
                                stream.Position = 0;

                                return File(stream, "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "electrical-approval-error.doc");//rjc 20130426

                            }
                            //   Change  by Arun 24 Feb 2014   Electricak Automatic
                            //   _propertyRepository.UpdateElectricalWorkStatus(model.selectedRows, ElectricalWorkStatus.AwaitingElectricalApproval, User.Identity.GetUserId().Value);
                            tx.Commit();
                        }
                    }
                    break;

                case BulkAction.GenerateContactUsLetter:
                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        var propertyBatch = new PropertyBatch();
                        if (inspectionStatus.HasValue)
                        {
                            //RJC. 20130604 New Feature. Need to only update this if selected by the user 

                            var r = form.GetValue("contactUsStatusUpdateOption");
                            if (r.AttemptedValue == "UpdateStatus")
                            {
                                _propertyRepository.UpdateInspectionStatus(model.selectedRows, inspectionStatus.Value, User.Identity.GetUserId().Value);
                            }
                            propertyBatch.StatusId = (int)inspectionStatus.Value;
                        }
                        if (electricalWorkStatus.HasValue)
                        {
                            _propertyRepository.UpdateElectricalWorkStatus(model.selectedRows, electricalWorkStatus.Value, User.Identity.GetUserId().Value);
                            propertyBatch.StatusId = (int)electricalWorkStatus.Value;
                        }

                        using (var tx = TransactionFactory.BeginTransaction("Create Property Batch"))
                        {
                            propertyBatch.BulkActionId = (int)BulkAction.GenerateContactUsLetter;
                            propertyBatch.Date = DateTime.Today;
                            foreach (var rowId in selectedRows)
                            {
                                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                            }
                            Repository.Save(propertyBatch);
                            tx.Commit();
                        }
                        return GenerateContactUsLetter(propertyBatch.Id);
                    }
                    break;

                case BulkAction.RequestForContactDetailsUpdate:
                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        if (inspectionStatus.HasValue)
                        {
                            _propertyRepository.UpdateInspectionStatus(model.selectedRows, inspectionStatus.Value, User.Identity.GetUserId().Value);
                        }
                        if (electricalWorkStatus.HasValue)
                        {
                            _propertyRepository.UpdateElectricalWorkStatus(model.selectedRows, electricalWorkStatus.Value, User.Identity.GetUserId().Value);
                        }
                        return RequestForContactDetailsUpdate(userProfile);
                    }
                    break;
                case BulkAction.ExportForContactDetailsUpdate:
                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        var propertyBatch = new PropertyBatch();
                        if (inspectionStatus.HasValue)
                        {
                            _propertyRepository.UpdateInspectionStatus(model.selectedRows, inspectionStatus.Value, User.Identity.GetUserId().Value);
                            propertyBatch.StatusId = (int)inspectionStatus.Value;
                        }
                        if (electricalWorkStatus.HasValue)
                        {
                            _propertyRepository.UpdateElectricalWorkStatus(model.selectedRows, electricalWorkStatus.Value, User.Identity.GetUserId().Value);
                            propertyBatch.StatusId = (int)electricalWorkStatus.Value;
                        }

                        using (var tx = TransactionFactory.BeginTransaction("Export for Contact Details Update"))
                        {
                            propertyBatch.BulkActionId = (int)BulkAction.ExportForContactDetailsUpdate;
                            propertyBatch.Date = DateTime.Today;
                            foreach (var rowId in selectedRows)
                            {
                                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                            }
                            Repository.Save(propertyBatch);
                            tx.Commit();
                        }
                        return ExportForContactDetailsUpdate(userProfile, propertyBatch);
                    }
                    break;
                case BulkAction.GenerateElectricanJobReport:
                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        _propertyRepository.UpdateElectricalWorkStatus(model.selectedRows, electricalWorkStatus.Value, User.Identity.GetUserId().Value);
                        var propertyBatch = new PropertyBatch();
                        using (var tx = TransactionFactory.BeginTransaction("Create Electrician Job Report"))
                        {
                            propertyBatch.BulkActionId = (int)BulkAction.GenerateElectricanJobReport;
                            propertyBatch.StatusId = (int)electricalWorkStatus.Value;
                            propertyBatch.Date = DateTime.Today;
                            foreach (var rowId in selectedRows)
                            {
                                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                            }
                            Repository.Save(propertyBatch);
                            tx.Commit();
                        }
                        return GenerateElectricianJobReport(propertyBatch);
                    }
                    break;
                case BulkAction.GenerateEmailWithPropertyServiceHistory:
                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        var propertyBatch = new PropertyBatch();
                        using (var tx = TransactionFactory.BeginTransaction("Create Email with Property Service History"))
                        {
                            propertyBatch.BulkActionId = (int)BulkAction.GenerateEmailWithPropertyServiceHistory;
                            propertyBatch.StatusId = (int)InspectionStatus.ReadyForService;
                            propertyBatch.Date = DateTime.Today;
                            foreach (var rowId in selectedRows)
                            {
                                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                            }
                            Repository.Save(propertyBatch);
                            tx.Commit();
                        }
                        return GenerateEmailWithPropertyServiceHistory(userProfile, propertyBatch);
                    }
                    break;

                case BulkAction.CreateBulkList:
                    if (TryUpdateModel(model, form.ToValueProvider()))
                    {
                        var propertyBatch = new PropertyBatch();
                        using (var tx = TransactionFactory.BeginTransaction("CreateBulkList"))
                        {
                            propertyBatch.BulkActionId = (int)BulkAction.CreateBulkList;
                            propertyBatch.Date = DateTime.Today;
                            foreach (var rowId in selectedRows)
                            {
                                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                            }
                            Repository.Save(propertyBatch);
                            tx.Commit();
                        }
                        return Json(new { success = true, message = "Batch number is " + propertyBatch.Id.ToString() });
                    }
                    break;

                case BulkAction.HoldProperties:
                    if (!electricalWorkStatus.HasValue && !inspectionStatus.HasValue)
                    {
                        return Json(new { success = false, message = "No Status selected" });
                    }
                    var propertyHoldBatch = new PropertyBatch();
                    if (inspectionStatus.HasValue)
                    {
                        _propertyRepository.HoldProperties(selectedRows, inspectionStatus, electricalWorkStatus, notes, notificationDate, User.Identity.GetUserId().Value);
                        propertyHoldBatch.StatusId = (int)inspectionStatus.Value;
                    }
                    if (electricalWorkStatus.HasValue)
                    {
                        _propertyRepository.HoldProperties(selectedRows, inspectionStatus, electricalWorkStatus, notes, notificationDate, User.Identity.GetUserId().Value);
                        propertyHoldBatch.StatusId = (int)electricalWorkStatus.Value;
                    }

                    using (var tx = TransactionFactory.BeginTransaction("Create Property Batch"))
                    {
                        propertyHoldBatch.BulkActionId = (int)BulkAction.HoldProperties;
                        propertyHoldBatch.Date = model.notificationDate.HasValue ? model.notificationDate.Value : DateTime.Today;
                        foreach (var rowId in selectedRows)
                        {
                            propertyHoldBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                        }
                        Repository.Save(propertyHoldBatch);
                        tx.Commit();
                    }
                    break;
            }
            return Json(new { success = true });
        }

        private FileStreamResult GenerateElectricianJobReport(PropertyBatch propertyBatch)
        {

            DataTable table = new DataTable();
            table.Columns.Add("Property Id");
            table.Columns.Add("Address");
            table.Columns.Add("Agency");
            table.Columns.Add("Tenant");
            table.Columns.Add("Contact Number");
            table.Columns.Add("Status");
            table.Columns.Add("* Please note the exact number of smoke detectors that need to be replaced in each property");

            foreach (var item in propertyBatch.PropertyInfo)
            {
                var serviceNotes = string.Empty;
                // rjc Changed as requested by Jason so that "service" just uses the last service sheet regardless of whether it has ElectricianRequired selected 
                var service = item.LastServiceSheetNoConditions;//LastElectricanRequiredServiceSheet;
                if (service != null)
                {
                    serviceNotes = service.ServiceSheet.ElectricalNotes;
                    var serviceItems = new StringBuilder();
                    var electricalDetails = string.Empty;

                    var expiredItemCount = service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItems.Count();
                    var expiredItems = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItems
                                        orderby serviceItem.ExpiryYear
                                        select serviceItem.ExpiryYear).Distinct().ToList();

                    serviceItems.Append(string.Format("Replace {0} x detectors with expiry {1}", expiredItemCount, string.Join(",", expiredItems)));
                    serviceItems.Append(string.IsNullOrEmpty(serviceNotes) ? string.Empty : " - " + serviceNotes);
                    table.Rows.Add(item.PropertyNumber.ToString(), item.ToString(), item.Agency.Name, item.OccupantName, item.GetTenantPropertyPhones(), item.ElectricalWorkStatus.GetDescription(), serviceItems.ToString());
                }

            }


            var bytes = Encoding.GetEncoding("iso-8859-1").GetBytes(table.ToCSV());
            var stream = new MemoryStream(bytes);


            return File(stream, "text/csv", "electrical-job-report.csv");
        }

        private string GetBookingItemDescriptions(IEnumerable<DetectorInspector.Model.Booking> activeBookings)
        {
            string details = "";
            var bookings = from b in activeBookings
                           where b.IsInvoiced.Equals(false)
                           select b;
            foreach (var booking in bookings)
            {

                if (booking.ServiceSheet != null)
                {
                    // if (booking.ServiceSheet.IsElectrical)
                    {
                        var detectorCount = QuickBooksDataUtil.GetElectricalDetectorCount(booking);
                        var detectorServiceItem = QuickBooksDataUtil.GetServiceItem(booking, Repository, detectorCount);
                        details += "\\n" + detectorServiceItem.QuickBooksFreeAndFixedFeeDescription;
                        var replacedServiceItemCount = QuickBooksDataUtil.GetReplacedServiceItemWithoutMainsCount(booking);

                        if (replacedServiceItemCount > 0)
                        {
                            var smokeDetectorServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector);
                            details += "\\n" + smokeDetectorServiceItem.QuickBooksFreeAndFixedFeeDescription.Replace("${numberofdetectors}", replacedServiceItemCount.ToString());
                        }
                    }
                }
            }
            return details;
        }

        //private string ExportInspectionInvoice(PropertyBatch propertyBatch)
        ////    private FileStreamResult ExportInspectionInvoice(PropertyBatch propertyBatch, ref int c)
        ////    private Array ExportInspectionInvoice(PropertyBatch propertyBatch)
        //{
        //    //var discount = Repository.Get<ServiceItem>((int)SystemServiceItem.Discount);
        //    //   c = 10;
        //    var invoiceExport = new InvoiceExport();
        //    // Code change by Arun
        //    //  ArrayList arrlist = new ArrayList();
        //    //  Session["Message"] = "";


        //    using (var tx = TransactionFactory.BeginTransaction("Create Inspection Invoice"))
        //    {
        //        foreach (var item in propertyBatch.PropertyInfo)
        //        {
        //            item.UpdateExpiryYears();

        //            Repository.Save(item);

        //            var isInvoiced = false;
        //            decimal discount = 0;

        //            if (item.Agency.Discount > 0)
        //            {
        //                discount = item.Agency.Discount;
        //            }


        //            bool isFixedFeeService = item.IsFixedFeeService;

        //            if (item.Agency != null)
        //            {
        //                isFixedFeeService |= (item.Agency.IsFixedFeeService == true);
        //            }

        //            if (item.PropertyManager != null)
        //            {
        //                isFixedFeeService |= (item.PropertyManager.IsFixedFeeService == true);
        //            }

        //            if (isFixedFeeService)
        //            {
        //                var lineItems = new List<InvoiceTransactionLineItem>();
        //                var fixedFeeServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.FixedFeeService);
        //                string fixedFeeServiceDetails = GetBookingItemDescriptions(item.ActiveBookings);


        //                IEnumerable<DetectorInspector.Model.Booking> bookings = from b in item.ActiveBookings
        //                                                                        where b.IsInvoiced.Equals(false)
        //                                                                        orderby b.Date descending
        //                                                                        select b;
        //                DetectorInspector.Model.Booking currentBooking = null;
        //                // get first in list is there is anything in the list 
        //                foreach (var booking in bookings)
        //                {
        //                    currentBooking = booking;
        //                    break;
        //                }

        //                lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, fixedFeeServiceItem, 1, discount, fixedFeeServiceDetails));

        //                if (item.DiscountPercentage != 0)
        //                {
        //                    ServiceItem discountLineItem = Repository.Get<ServiceItem>((int)SystemServiceItem.ServiceFeeDiscount);// RJC. Apparently ServiceFeeDiscount is actually property discount !!
        //                    discountLineItem.Price = -1 * (fixedFeeServiceItem.Price - discount) * (item.DiscountPercentage / 100);// property discount % is taken on full price less Agency discount ($)
        //                    lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, discountLineItem, 1, 0, discountLineItem.QuickBooksFreeAndFixedFeeDescription));
        //                }
        //                //add the transaction
        //                invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

        //                currentBooking.IsInvoiced = true;
        //                Repository.Save<Model.Booking>(currentBooking);
        //            }
        //            else
        //            {
        //                if (item.IsFreeService == true)
        //                {
        //                    var lineItems = new List<InvoiceTransactionLineItem>();
        //                    var fixedFeeServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.FreeService);
        //                    string freeServiceDetails = GetBookingItemDescriptions(item.ActiveBookings);

        //                    IEnumerable<DetectorInspector.Model.Booking> bookings = from b in item.ActiveBookings
        //                                                                            where b.IsInvoiced.Equals(false)
        //                                                                            orderby b.Date descending
        //                                                                            select b;
        //                    DetectorInspector.Model.Booking currentBooking = null;
        //                    // get first in list is there is anything in the list 
        //                    foreach (var booking in bookings)
        //                    {
        //                        currentBooking = booking;
        //                        break;
        //                    }

        //                    lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, fixedFeeServiceItem, 1, 0, freeServiceDetails));
        //                    //add the transaction
        //                    invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

        //                    currentBooking.IsInvoiced = true;
        //                    Repository.Save<Model.Booking>(currentBooking);
        //                }
        //                else
        //                {

        //                    if (item.ElectricalWorkStatus.Equals(ElectricalWorkStatus.ElectricalApprovalRejected))
        //                    {

        //                        SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Default"].ConnectionString);
        //                        using (var cmd = new SqlCommand("p_PropertyBatchItemAutomaticTable_GetItems", (SqlConnection)conn))
        //                        {
        //                            cmd.CommandType = CommandType.StoredProcedure;
        //                            cmd.Parameters.AddWithValue("@PropertyInfo", item.Id);
        //                            if (conn.State == ConnectionState.Closed)
        //                            {
        //                                conn.Open();
        //                            }
        //                            using (var dr = cmd.ExecuteReader())
        //                            {
        //                                //  while (dr.Read())
        //                                dr.Read();
        //                                {
        //                                    // var PropertyId;
        //                                    if (dr.HasRows == true)
        //                                    {
        //                                        //  var PId = dr.GetInt32("PropertyInfo");
        //                                        //    PropertyId = PropertyId + "," + PId;
        //                                        //  PIdetail = item.StreetNumber + item.StreetName + item.Suburb + item.State.Name;
        //                                        if (Propertydetails == null)
        //                                        {
        //                                            Propertydetails = item.StreetNumber + " " + item.StreetName + " " + item.Suburb + " " + item.State.Name;
        //                                        }
        //                                        else
        //                                        {
        //                                            Propertydetails = Propertydetails + " " + ", " + item.StreetNumber + " " + item.StreetName + " " + item.Suburb + " " + item.State.Name;
        //                                            item.Propertydetails = Propertydetails;
        //                                            break;
        //                                        }

        //                                    }

        //                                    else
        //                                    {




        //                                        var electricalCallout = Repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalCallOut);
        //                                        var lineItems = new List<InvoiceTransactionLineItem>();

        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, null, electricalCallout, 1, discount));

        //                                        invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

        //                                        isInvoiced = true;

        //                                        item.Cancel(ElectricalWorkStatus.ElectricalApprovalRejected.GetDescription());
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }

        //                    var bookings = from b in item.ActiveBookings
        //                                   where b.IsInvoiced.Equals(false)
        //                                   select b;
        //                    foreach (var booking in bookings)
        //                    {

        //                        var lineItems = new List<InvoiceTransactionLineItem>();

        //                        if (!isInvoiced)
        //                        {
        //                            if (booking.ServiceSheet != null)
        //                            {
        //                                //discount = discount + booking.ServiceSheet.Discount;
        //                                //if the service sheet is electrical, we need to invoice for the detectors, electrical service and the certificate
        //                                //we may also need to invoice for non electrical items as well
        //                                if (booking.ServiceSheet.IsElectrical)
        //                                {


        //                                    var detectorCount = QuickBooksDataUtil.GetElectricalDetectorCountMainsOrSecurity(booking);

        //                                    var detectorServiceItem = QuickBooksDataUtil.GetServiceItem(booking, Repository, detectorCount);

        //                                    var certificateServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.Certificate);

        //                                    var smokeDetectorServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector);

        //                                    decimal discnt = detectorServiceItem.Price * booking.PropertyInfo.DiscountPercentage / 100;

        //                                    booking.PropertyInfo.Discount = decimal.Round(discnt, 2);// rjc. 20130319 Hack to use property % discount on electrical service items, as requested by Jason.
        //                                    //electrical service
        //                                    lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, detectorServiceItem, 1, discount));


        //                                    // mains detector (not security mains)
        //                                    var mainsDetectorCount = QuickBooksDataUtil.GetElectricalDetectorCountMains(booking);

        //                                    if (mainsDetectorCount > 0)
        //                                    {
        //                                        var electricalServiceServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalMainDetector);
        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, electricalServiceServiceItem, mainsDetectorCount, 0));
        //                                    }

        //                                    // mains detector (not security mains)
        //                                    var securityDetectorCount = QuickBooksDataUtil.GetElectricalDetectorCountSecurity(booking);

        //                                    if (securityDetectorCount > 0)
        //                                    {
        //                                        var electricalServiceServiceItemSecurity = Repository.Get<ServiceItem>((int)SystemServiceItem.SecurityDetector);
        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, electricalServiceServiceItemSecurity, securityDetectorCount, 0));
        //                                    }
        //                                    //certificate
        //                                    lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, certificateServiceItem, 1, 0));

        //                                    var replacedServiceItemCount = QuickBooksDataUtil.GetReplacedServiceItemWithoutMainsCount(booking);

        //                                    if (replacedServiceItemCount > 0)
        //                                    {
        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, smokeDetectorServiceItem, replacedServiceItemCount, 0));
        //                                    }

        //                                    //add the transaction
        //                                    invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, booking, item));
        //                                }
        //                                else
        //                                {
        //                                    var serviceItem = QuickBooksDataUtil.GetServiceItem(booking, Repository, 0);
        //                                    var smokeDetectorServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector);


        //                                    // rjc 20130403
        //                                    var zoneCharge = GetPropertyZoneCharge(booking.PropertyInfo);
        //                                    decimal discnt = (zoneCharge - discount) * booking.PropertyInfo.DiscountPercentage / 100;
        //                                    booking.PropertyInfo.Discount = decimal.Round(discnt, 2);

        //                                    // Non Electrical Items
        //                                    lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, serviceItem, 1, discount));

        //                                    var replacedServiceItemCount = QuickBooksDataUtil.GetReplacedServiceItemCount(booking);

        //                                    if (replacedServiceItemCount > 0)
        //                                    {
        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, smokeDetectorServiceItem, replacedServiceItemCount, 0));
        //                                    }

        //                                    invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, booking, item));
        //                                }


        //                            }
        //                        }


        //                        booking.IsInvoiced = true;
        //                        Repository.Save<Model.Booking>(booking);
        //                    }
        //                }// Not fixed fee service
        //            }

        //            if (item.IsOneOffService)
        //            {
        //                item.Cancel("Once off service");
        //            }

        //            item.ContactNotes = "";// RJC 20130314 - Issue 2 from Jason's list, erase contact notes when item is invoiced.
        //            Repository.Save(item);// Now save the changes
        //        } // foreach
        //        tx.Commit();


        //    }// using....

        //    string iifStr = invoiceExport.ToString();
        //    var bytes = Encoding.GetEncoding("iso-8859-1").GetBytes(iifStr);
        //    //			var bytes = Encoding.GetEncoding("utf-8").GetBytes(invoiceExport.ToString());// To Do need to encode wider rang of chars, possible use windows char set 12xx
        //    var stream = new MemoryStream(bytes);
        //    //var fileiif = File(stream, "text/csv", "invoice.iif");
        //    //arrlist.Add(fileiif);
        //    //PropertydetailMessage = Propertydetails + "Invoices for these properties have not be generated as they are from Electrician Required (Automatic): then list the properties";
        //    //arrlist.Add(PropertydetailMessage);

        //    //  string BackBtnVal = Convert.ToString(Request["hidBack"]);
        //    //  .ClientScript.RegisterStartupScript(this.GetType(), "BckBtn", "document.getElementById('hidBck').value = '" + BackBtnVal + "';", true);

        //    //   lblKeyword.Text = "";
        //    //foreach (var item in propertyBatch.PropertyInfo)
        //    //{
        //    //    item.Propertydetails = PropertydetailMessage;
        //    //}
        //    // ViewData["Message"] = PropertydetailMessage;
        //    if (Propertydetails != null)
        //    {
        //        Session["Message"] = "Invoices for these properties have not be generated as they are from Electrician Required (Automatic): " + Propertydetails;
        //    }

        //    // var model = new Model.PropertyInfoSearchResult();
        //    //  model.Prop = "window.alert(' this is from action');";
        //    //var model123 = new PropertyInfoSearchViewModel(Repository, false, true);
        //    //model123.R = "window.alert(' this is from action');";

        //    UpdateMessage();
        //    TempData["Update"] = "aaa";
        //    // ViewData["Message"] = "text";
        //    //for (int i = 0; i < arrlist.Count; i++)
        //    //{
        //    //    // return File(arrlist[i].ToString() + "<br />");
        //    //    return File(stream, "text/csv", "invoice.iif");
        //    //}
        //    // ViewData.Values = @"<script type='text/javascript' language='javascript'>alert(""Hello World!"")</script>"; ;
        //    //ViewBag.message = @"<script type='text/javascript' language='javascript'>alert(""Hello World!"")</script>"; ;
        //    //     return JavaScript("Callback()");
        //    return iifStr;
        //    //return File(stream, "text/csv", "invoice.iif");
        //    // return arrlist;
        //}


        //private string ExportInspectionInvoice(PropertyBatch propertyBatch)
        ////    private FileStreamResult ExportInspectionInvoice(PropertyBatch propertyBatch, ref int c)
        ////    private Array ExportInspectionInvoice(PropertyBatch propertyBatch)
        //{
        //    //var discount = Repository.Get<ServiceItem>((int)SystemServiceItem.Discount);
        //    //   c = 10;
        //    var invoiceExport = new InvoiceExport();
        //    // Code change by Arun
        //    //  ArrayList arrlist = new ArrayList();
        //    //  Session["Message"] = "";


        //    using (var tx = TransactionFactory.BeginTransaction("Create Inspection Invoice"))
        //    {
        //        foreach (var item in propertyBatch.PropertyInfo)
        //        {
        //            item.UpdateExpiryYears();

        //            Repository.Save(item);

        //            var isInvoiced = false;
        //            decimal discount = 0;

        //            if (item.Agency.Discount > 0)
        //            {
        //                discount = item.Agency.Discount;
        //            }


        //            bool isFixedFeeService = item.IsFixedFeeService;

        //            if (item.Agency != null)
        //            {
        //                isFixedFeeService |= (item.Agency.IsFixedFeeService == true);
        //            }

        //            if (item.PropertyManager != null)
        //            {
        //                isFixedFeeService |= (item.PropertyManager.IsFixedFeeService == true);
        //            }

        //            if (isFixedFeeService)
        //            {
        //                var lineItems = new List<InvoiceTransactionLineItem>();
        //                var fixedFeeServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.FixedFeeService);
        //                string fixedFeeServiceDetails = GetBookingItemDescriptions(item.ActiveBookings);


        //                IEnumerable<DetectorInspector.Model.Booking> bookings = from b in item.ActiveBookings
        //                                                                        where b.IsInvoiced.Equals(false)
        //                                                                        orderby b.Date descending
        //                                                                        select b;
        //                DetectorInspector.Model.Booking currentBooking = null;
        //                // get first in list is there is anything in the list 
        //                foreach (var booking in bookings)
        //                {
        //                    currentBooking = booking;
        //                    break;
        //                }

        //                lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, fixedFeeServiceItem, 1, discount, fixedFeeServiceDetails));

        //                if (item.DiscountPercentage != 0)
        //                {
        //                    ServiceItem discountLineItem = Repository.Get<ServiceItem>((int)SystemServiceItem.ServiceFeeDiscount);// RJC. Apparently ServiceFeeDiscount is actually property discount !!
        //                    discountLineItem.Price = -1 * (fixedFeeServiceItem.Price - discount) * (item.DiscountPercentage / 100);// property discount % is taken on full price less Agency discount ($)
        //                    lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, discountLineItem, 1, 0, discountLineItem.QuickBooksFreeAndFixedFeeDescription));
        //                }
        //                //add the transaction
        //                invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

        //                currentBooking.IsInvoiced = true;
        //                Repository.Save<Model.Booking>(currentBooking);
        //            }
        //            else
        //            {
        //                if (item.IsFreeService == true)
        //                {
        //                    var lineItems = new List<InvoiceTransactionLineItem>();
        //                    var fixedFeeServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.FreeService);
        //                    string freeServiceDetails = GetBookingItemDescriptions(item.ActiveBookings);

        //                    IEnumerable<DetectorInspector.Model.Booking> bookings = from b in item.ActiveBookings
        //                                                                            where b.IsInvoiced.Equals(false)
        //                                                                            orderby b.Date descending
        //                                                                            select b;
        //                    DetectorInspector.Model.Booking currentBooking = null;
        //                    // get first in list is there is anything in the list 
        //                    foreach (var booking in bookings)
        //                    {
        //                        currentBooking = booking;
        //                        break;
        //                    }

        //                    lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, fixedFeeServiceItem, 1, 0, freeServiceDetails));
        //                    //add the transaction
        //                    invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

        //                    currentBooking.IsInvoiced = true;
        //                    Repository.Save<Model.Booking>(currentBooking);
        //                }
        //                else
        //                {

        //                    if (item.ElectricalWorkStatus.Equals(ElectricalWorkStatus.ElectricalApprovalRejected))
        //                    {

        //                        SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Default"].ConnectionString);
        //                        using (var cmd = new SqlCommand("p_PropertyBatchItemAutomaticTable_GetItems", (SqlConnection)conn))
        //                        {
        //                            cmd.CommandType = CommandType.StoredProcedure;
        //                            cmd.Parameters.AddWithValue("@PropertyInfo", item.Id);
        //                            if (conn.State == ConnectionState.Closed)
        //                            {
        //                                conn.Open();
        //                            }
        //                            using (var dr = cmd.ExecuteReader())
        //                            {
        //                                //  while (dr.Read())
        //                                dr.Read();
        //                                {
        //                                    // var PropertyId;
        //                                    if (dr.HasRows == true)
        //                                    {
        //                                        //  var PId = dr.GetInt32("PropertyInfo");
        //                                        //    PropertyId = PropertyId + "," + PId;
        //                                        //  PIdetail = item.StreetNumber + item.StreetName + item.Suburb + item.State.Name;
        //                                        if (Propertydetails == null)
        //                                        {
        //                                            Propertydetails = item.StreetNumber + " " + item.StreetName + " " + item.Suburb + " " + item.State.Name;
        //                                        }
        //                                        else
        //                                        {
        //                                            Propertydetails = Propertydetails + " " + ", " + item.StreetNumber + " " + item.StreetName + " " + item.Suburb + " " + item.State.Name;
        //                                            //   item.Propertydetails = Propertydetails;
        //                                            break;
        //                                        }

        //                                    }

        //                                    else
        //                                    {




        //                                        var electricalCallout = Repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalCallOut);
        //                                        var lineItems = new List<InvoiceTransactionLineItem>();

        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, null, electricalCallout, 1, discount));

        //                                        invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

        //                                        isInvoiced = true;

        //                                        item.Cancel(ElectricalWorkStatus.ElectricalApprovalRejected.GetDescription());
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }

        //                    var bookings = from b in item.ActiveBookings
        //                                   where b.IsInvoiced.Equals(false)
        //                                   select b;
        //                    foreach (var booking in bookings)
        //                    {

        //                        var lineItems = new List<InvoiceTransactionLineItem>();

        //                        if (!isInvoiced)
        //                        {
        //                            if (booking.ServiceSheet != null)
        //                            {
        //                                //discount = discount + booking.ServiceSheet.Discount;
        //                                //if the service sheet is electrical, we need to invoice for the detectors, electrical service and the certificate
        //                                //we may also need to invoice for non electrical items as well
        //                                if (booking.ServiceSheet.IsElectrical)
        //                                {


        //                                    var detectorCount = QuickBooksDataUtil.GetElectricalDetectorCountMainsOrSecurity(booking);

        //                                    var detectorServiceItem = QuickBooksDataUtil.GetServiceItem(booking, Repository, detectorCount);

        //                                    var certificateServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.Certificate);

        //                                    var smokeDetectorServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector);

        //                                    decimal discnt = detectorServiceItem.Price * booking.PropertyInfo.DiscountPercentage / 100;

        //                                    booking.PropertyInfo.Discount = decimal.Round(discnt, 2);// rjc. 20130319 Hack to use property % discount on electrical service items, as requested by Jason.
        //                                    //electrical service
        //                                    lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, detectorServiceItem, 1, discount));


        //                                    // mains detector (not security mains)
        //                                    var mainsDetectorCount = QuickBooksDataUtil.GetElectricalDetectorCountMains(booking);

        //                                    if (mainsDetectorCount > 0)
        //                                    {
        //                                        var electricalServiceServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalMainDetector);
        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, electricalServiceServiceItem, mainsDetectorCount, 0));
        //                                    }

        //                                    // mains detector (not security mains)
        //                                    var securityDetectorCount = QuickBooksDataUtil.GetElectricalDetectorCountSecurity(booking);

        //                                    if (securityDetectorCount > 0)
        //                                    {
        //                                        var electricalServiceServiceItemSecurity = Repository.Get<ServiceItem>((int)SystemServiceItem.SecurityDetector);
        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, electricalServiceServiceItemSecurity, securityDetectorCount, 0));
        //                                    }
        //                                    //certificate
        //                                    lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, certificateServiceItem, 1, 0));

        //                                    var replacedServiceItemCount = QuickBooksDataUtil.GetReplacedServiceItemWithoutMainsCount(booking);

        //                                    if (replacedServiceItemCount > 0)
        //                                    {
        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, smokeDetectorServiceItem, replacedServiceItemCount, 0));
        //                                    }

        //                                    //add the transaction
        //                                    invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, booking, item));
        //                                }
        //                                else
        //                                {
        //                                    var serviceItem = QuickBooksDataUtil.GetServiceItem(booking, Repository, 0);
        //                                    var smokeDetectorServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector);


        //                                    // rjc 20130403
        //                                    var zoneCharge = GetPropertyZoneCharge(booking.PropertyInfo);
        //                                    decimal discnt = (zoneCharge - discount) * booking.PropertyInfo.DiscountPercentage / 100;
        //                                    booking.PropertyInfo.Discount = decimal.Round(discnt, 2);

        //                                    // Non Electrical Items
        //                                    lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, serviceItem, 1, discount));

        //                                    var replacedServiceItemCount = QuickBooksDataUtil.GetReplacedServiceItemCount(booking);

        //                                    if (replacedServiceItemCount > 0)
        //                                    {
        //                                        lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, smokeDetectorServiceItem, replacedServiceItemCount, 0));
        //                                    }

        //                                    invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, booking, item));
        //                                }


        //                            }
        //                        }


        //                        booking.IsInvoiced = true;
        //                        Repository.Save<Model.Booking>(booking);
        //                    }
        //                }// Not fixed fee service
        //            }

        //            if (item.IsOneOffService)
        //            {
        //                item.Cancel("Once off service");
        //            }

        //            item.ContactNotes = "";// RJC 20130314 - Issue 2 from Jason's list, erase contact notes when item is invoiced.
        //            Repository.Save(item);// Now save the changes
        //        } // foreach
        //        tx.Commit();


        //    }// using....

        //    string iifStr = invoiceExport.ToString();
        //    //  var bytes = Encoding.GetEncoding("iso-8859-1").GetBytes(iifStr);
        //    //			var bytes = Encoding.GetEncoding("utf-8").GetBytes(invoiceExport.ToString());// To Do need to encode wider rang of chars, possible use windows char set 12xx
        //    // var stream = new MemoryStream(bytes);
        //    //var fileiif = File(stream, "text/csv", "invoice.iif");
        //    //arrlist.Add(fileiif);
        //    //PropertydetailMessage = Propertydetails + "Invoices for these properties have not be generated as they are from Electrician Required (Automatic): then list the properties";
        //    //arrlist.Add(PropertydetailMessage);

        //    //  string BackBtnVal = Convert.ToString(Request["hidBack"]);
        //    //  .ClientScript.RegisterStartupScript(this.GetType(), "BckBtn", "document.getElementById('hidBck').value = '" + BackBtnVal + "';", true);

        //    //   lblKeyword.Text = "";
        //    //foreach (var item in propertyBatch.PropertyInfo)
        //    //{
        //    //    item.Propertydetails = PropertydetailMessage;
        //    //}
        //    // ViewData["Message"] = PropertydetailMessage;
        //    if (Propertydetails != null)
        //    {
        //        Session["Message"] = "Invoices for these properties have not be generated as they are from Electrician Required (Automatic): " + Propertydetails;
        //    }
        //    return invoiceExport.ToString();

        //    // var model = new Model.PropertyInfoSearchResult();
        //    //  model.Prop = "window.alert(' this is from action');";
        //    //var model123 = new PropertyInfoSearchViewModel(Repository, false, true);
        //    //model123.R = "window.alert(' this is from action');";

        //    //  UpdateMessage();
        //    // TempData["Update"] = "aaa";
        //    // ViewData["Message"] = "text";
        //    //for (int i = 0; i < arrlist.Count; i++)
        //    //{
        //    //    // return File(arrlist[i].ToString() + "<br />");
        //    //    return File(stream, "text/csv", "invoice.iif");
        //    //}
        //    // ViewData.Values = @"<script type='text/javascript' language='javascript'>alert(""Hello World!"")</script>"; ;
        //    //ViewBag.message = @"<script type='text/javascript' language='javascript'>alert(""Hello World!"")</script>"; ;
        //    //     return JavaScript("Callback()");
        //    //   return stream.ToString();
        //    //  return File(stram, "text/csv", "invoice.iif");
        //    // return arrlist;
        //}




        private FileStreamResult ExportProperties(IEnumerable<int> selectedRows)
        {
            DbExportContext context = new DbExportContext(ExportFormat.Xls);
            var command = context.GetCommand("p_PropertyInfo__Retrieve", CommandType.StoredProcedure);
            command.Parameters.Add(context.GetParameter("@selectedRows", string.Join(",", (from j in selectedRows select j.ToString("D")).ToArray())));
            var stream = context.Export(command, "Sheet1");
            return File(stream, "application/vnd.ms-excel", "property-export.xls");
        }

        private FileStreamResult ExportMobileNumberForSMS(DateTime notificationDate)
        {
            return File(_notificationService.ExportMobileNumberForSMS(notificationDate), "text/plain", "mobile.txt");
        }

        private FileStreamResult GenerateNotificationLetter(int id, BulkActionViewModel theModel, string templateDoc)
        {



            BatchViewModel bvm;


            bvm = new BatchViewModel(Repository, null, SystemNotification.GenerateNotificationLetter, id);




            var memoryStream = new MemoryStream();

            WordDocGenerator wd = new WordDocGenerator(templateDoc, memoryStream);
            foreach (object itemData in bvm.EntryNotificationWordDocData)
            {
                wd.AddPage(itemData);
            }

            wd.Save();
            memoryStream.Seek(0, SeekOrigin.Begin);



            // return File(memoryStream, "application/msword", "entry-notification-letter.doc");
            MemoryStream outputStream = new MemoryStream();
            using (ZipFile zip = new ZipFile())
            {
                zip.AddEntry("Agency.docx", memoryStream);
                zip.AddEntry("Tennant.pdf", _notificationService.GenerateNotificationLetterZippeDocs(id));
                zip.Save(outputStream);
            }
            outputStream.Seek(0, SeekOrigin.Begin);
            return File(outputStream, "application/zip", "EntryNotifications.zip");

            // return File(_notificationService.GenerateNotificationLetterZippeDocs(id), "application/pdf", "entry-notification-letter.pdf");
        }


        private FileStreamResult GenerateContactUsLetter(int id)
        {
            return File(_notificationService.GenerateContactUsLetter(id), "application/pdf", "contact-us-letter.pdf");
        }


        // 20140617 Added function to automatically 
        //private List<string> AutomaticallyAppoveFixedFeeAndFreeProperties(int batchID)
        //{
        //    bool isFixedFeeService;
        //    List<string> propertiesUpdated = new List<string>();
        //    StringBuilder messageText = new StringBuilder();
        //    messageText.Append("During - Generate Electrical Approval Quotation<br/>The following properties were automicatically approved because their were either Fixed Fee, or Free service.<br/><br/>");


        //    var propertyBatch = Repository.Get<PropertyBatch>(batchID);
        //    using (var tx = TransactionFactory.BeginTransaction("Automatic  Quotation Approval For Fee and Fixed Price Service"))
        //    {
        //        foreach (var propertyInfo in propertyBatch.PropertyInfo)
        //        {
        //            isFixedFeeService = propertyInfo.IsFixedFeeService;

        //            if (propertyInfo.Agency != null)
        //            {
        //                isFixedFeeService |= (propertyInfo.Agency.IsFixedFeeService == true);
        //            }

        //            if (propertyInfo.PropertyManager != null)
        //            {
        //                isFixedFeeService |= (propertyInfo.PropertyManager.IsFixedFeeService == true);
        //            }

        //            if (propertyInfo.ElectricalWorkStatus == ElectricalWorkStatus.NoElectricianRequired)
        //            {

        //            }

        //            //                    if (propertyInfo.IsFreeService == true || propertyInfo.IsFixedFeeService == true || propertyInfo.Agency.IsFixedFeeService == true || propertyInfo.PropertyManager.IsFixedFeeService == true)

        //            if (propertyInfo.IsFreeService == true || isFixedFeeService == true)
        //            {
        //                propertyInfo.ElectricalWorkStatus = ElectricalWorkStatus.ElectricalApprovalAccepted;

        //                messageText.Append(propertyInfo.ToString() + "<br/>");
        //                propertiesUpdated.Add(propertyInfo.ToString());
        //            }
        //        }
        //        Repository.Save(propertyBatch);
        //        tx.Commit();
        //    }



        //    if (propertiesUpdated.Count > 0)
        //    {
        //        var notification = Repository.Get<Notification>((int)SystemNotification.GenerateElectricalApprovalQuotationEmailAddress);


        //        // Need to extract the email address from the HTML "body" of the new notification
        //        // i.e We are re-using the existing notification items, which were initially intended to contain templated pages, to hold the email address
        //        // But its held in HTML, so the easiest way is just to use a regex (sourced from the web), to extract the address
        //        Regex emailRegex = new Regex(@"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*", RegexOptions.IgnoreCase);
        //        //find items that matches with our pattern
        //        MatchCollection emailMatches = emailRegex.Matches(notification.Body);


        //        string emailAddress = "";
        //        foreach (Match emailMatch in emailMatches)
        //        {
        //            emailAddress += emailMatch.Value;
        //            break;// only need the first one. We don't handle multiple email 
        //        }

        //        MailAddress to = new MailAddress(emailAddress);
        //        MailAddress from = new MailAddress("radolnik@detectorinspector.com.au");
        //        MailMessage message = new MailMessage(from, to);
        //        message.IsBodyHtml = true;
        //        message.Subject = "Generate Electrical Approval Quotation - Automatic approvals";
        //        message.Body = messageText.ToString();

        //        SmtpClient client = new SmtpClient();
        //        //client.Host = "mail.optusnet.com.au";

        //        Console.WriteLine("Sending an e-mail message to {0} at {1} by using the SMTP host={2}.", to.User, to.Host, client.Host);
        //        try
        //        {
        //            client.Send(message);
        //        }
        //        catch (Exception ex)
        //        {
        //            Console.WriteLine("Error sending email: {0}", ex.ToString());
        //        }
        //    }
        //    return propertiesUpdated;
        //}


        private List<string> AutomaticallyAppoveFixedFeeAndFreeProperties(PropertyBatch propertybatch)
        {
            bool isFixedFeeService;
            List<string> propertiesUpdated = new List<string>();
            StringBuilder messageText = new StringBuilder();
            messageText.Append("During - Generate Electrical Approval Quotation<br/>The following properties were automicatically approved because their were either Fixed Fee, or Free service.<br/><br/>");


            //var propertyBatch = Repository.Get<PropertyBatch>(batchID);
            var propertyBatch = propertybatch;
            using (var tx = TransactionFactory.BeginTransaction("Automatic  Quotation Approval For Fee and Fixed Price Service"))
            {
                foreach (var propertyInfo in propertyBatch.PropertyInfo)
                {
                    isFixedFeeService = propertyInfo.IsFixedFeeService;

                    if (propertyInfo.Agency != null)
                    {
                        isFixedFeeService |= (propertyInfo.Agency.IsFixedFeeService == true);
                    }

                    if (propertyInfo.PropertyManager != null)
                    {
                        isFixedFeeService |= (propertyInfo.PropertyManager.IsFixedFeeService == true);
                    }

                    if (propertyInfo.IsFreeService == true || isFixedFeeService == true)
                    {
                        propertyInfo.ElectricalWorkStatus = ElectricalWorkStatus.ElectricalApprovalAccepted;

                        messageText.Append(propertyInfo.ToString() + "<br/>");
                        propertiesUpdated.Add(propertyInfo.ToString());
                    }
                }
                Repository.Save(propertyBatch);
                tx.Commit();
            }

            if (propertiesUpdated.Count > 0)
            {
                var notification = Repository.Get<Notification>((int)SystemNotification.GenerateElectricalApprovalQuotationEmailAddress);


                // Need to extract the email address from the HTML "body" of the new notification
                // i.e We are re-using the existing notification items, which were initially intended to contain templated pages, to hold the email address
                // But its held in HTML, so the easiest way is just to use a regex (sourced from the web), to extract the address
                Regex emailRegex = new Regex(@"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*", RegexOptions.IgnoreCase);
                //find items that matches with our pattern
                //   MatchCollection emailMatches = emailRegex.Matches(notification.Body);
                MatchCollection emailMatches = emailRegex.Matches("Radolnik@detectorinspector.com.au");

                string emailAddress = "";
                foreach (Match emailMatch in emailMatches)
                {
                    emailAddress += emailMatch.Value;
                    break;// only need the first one. We don't handle multiple email 
                }

                MailAddress to = new MailAddress(emailAddress);
                MailAddress from = new MailAddress("radolnik@detectorinspector.com.au");
                MailMessage message = new MailMessage(from, to);
                message.IsBodyHtml = true;
                message.Subject = "Generate Electrical Approval Quotation - Automatic approvals";
                message.Body = messageText.ToString();

                SmtpClient client = new SmtpClient();
                //client.Host = "mail.optusnet.com.au";

                Console.WriteLine("Sending an e-mail message to {0} at {1} by using the SMTP host={2}.", to.User, to.Host, client.Host);
                try
                {
                    client.Send(message);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error sending email: {0}", ex.ToString());
                }
            }
            return propertiesUpdated;
        }
        //        private FileStreamResult GenerateElectricalApprovalQuotation(int id)
        //        {

        //            BatchViewModelForElectricalQuotes bvm;


        //            AutomaticallyAppoveFixedFeeAndFreeProperties(id);


        //            bvm = new BatchViewModelForElectricalQuotes(Repository, id);
        //#if true
        //            Stream result = _notificationService.GenerateElectricalApprovalQuotation(bvm.ElectricalQuoteData);



        //            //Use Word Doc version
        //            return File(result, "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "electrical-approval-quotation.doc");//rjc 20130426
        //#else            

        //            return File(_notificationService.GenerateElectricalApprovalQuotation(id), "application/pdf", "electrical-approval-quotation.pdf");//rjc 20130426
        //#endif

        //        }


        //   Change  by Arun 24 Feb 2014   Electricak Automatic

        private FileStreamResult GenerateElectricalApprovalQuotation(PropertyBatch propertybatch)
        {
            BatchViewModelForElectricalQuotes bvm;
            AutomaticallyAppoveFixedFeeAndFreeProperties(propertybatch);
            //    bvm = new BatchViewModelForElectricalQuotes(Repository, propertybatch);
            bvm = new BatchViewModelForElectricalQuotes(Repository, propertybatch, _propertyRepository);
#if true
            Stream result = _notificationService.GenerateElectricalApprovalQuotation(bvm.ElectricalQuoteData);
            //Use Word Doc version
            return File(result, "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "electrical-approval-quotation.doc");//rjc 20130426
#else            

			return File(_notificationService.GenerateElectricalApprovalQuotation(id), "application/pdf", "electrical-approval-quotation.pdf");//rjc 20130426
#endif

        }
        private FileStreamResult RequestForContactDetailsUpdate(UserProfile userProfile)
        {
            return File(_notificationService.RequestForContactDetailsUpdate(userProfile), "text/plain", "email.eml");
        }

        private FileStreamResult GenerateEmailWithPropertyServiceHistory(UserProfile userProfile, PropertyBatch propertyBatch)
        {

            return File(_notificationService.GenerateEmailWithPropertyServiceHistory(userProfile, propertyBatch), "text/plain", "email.eml");
        }

        private FileStreamResult ExportForContactDetailsUpdate(UserProfile userProfile, PropertyBatch propertyBatch)
        {
            DbExportContext context = new DbExportContext(ExportFormat.Xls);
            var command = context.GetCommand("p_PropertyInfo__TenantInfo", CommandType.StoredProcedure);
            command.Parameters.Add(context.GetParameter("@selectedRows", string.Join(",", (from j in propertyBatch.PropertyInfo select j.Id.ToString("D")).ToArray())));
            using (var stream = context.Export(command, "Console2007"))
            {
                IList<StreamModel> streams = new List<StreamModel>();

                var streamModel = new StreamModel("contact-details.xls", stream);
                streams.Add(streamModel);
                return File(_notificationService.ExportForContactDetailsUpdate(userProfile, streams), "text/plain",
                            "email.eml");
            }
        }


        //[HttpPost]
        //public ActionResult Create()
        //{

        //    using (var tx = TransactionFactory.BeginTransaction("Create Property"))
        //    {

        //        var model = new Model.PropertyInfo();

        //        model.IsDeleted = true;
        //        Repository.Save(model);

        //        try
        //        {
        //            tx.Commit();
        //            TempData["IsValid"] = true;

        //            return Json(new { success = true, id = model.Id });
        //        }
        //        catch (DataCurrencyException)
        //        {
        //            ShowErrorMessage("Save Failed",
        //                string.Format(SR.DataCurrencyException_Edit_Message, "PropertyInfo"));

        //            return Json(new { success = true, id = model.Id });
        //        }

        //    }


        //}

        [HttpPost]
        public ActionResult Create()
        {
            var model = new Model.PropertyInfo();

            return Json(new { success = true, id = model.Id });

        }

        [HttpGet]
        [Transactional]
        public ActionResult View(int id)
        {
            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, true, _agencyRepository);

            return View(model);
        }

        [HttpGet]
        [Transactional]
        public ActionResult Edit(int id)
        {
            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, true, _agencyRepository);
            model.PropertyInfo.IsDeleted = true;
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";


            // Jason requested that white space be removed from these items as it causes problem with keyword search

            form["PropertyInfo.UnitShopNumber"] = Regex.Replace(form["PropertyInfo.UnitShopNumber"].Trim(), @"\s+", " "); ;
            form["PropertyInfo.StreetNumber"] = Regex.Replace(form["PropertyInfo.StreetNumber"].Trim(), @"\s+", " "); ;
            form["PropertyInfo.StreetName"] = Regex.Replace(form["PropertyInfo.StreetName"].Trim(), @"\s+", " "); ;
            form["PropertyInfo.Suburb"] = Regex.Replace(form["PropertyInfo.Suburb"].Trim(), @"\s+", " "); ;

            using (var tx = TransactionFactory.BeginTransaction(action + " Property"))
            {
                var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, true, _agencyRepository);
                // If the user has selected that its a Private landlords job, the Agency needs to be set to the special faux agency.

                if (Int32.Parse(form["PropertyInfo.JobType"].ToString()) == (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged)
                {
                    form["PropertyInfo.PrivateLandlordBillTo"] = DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.PrivateLandlordBillToTypeEnum.BillToAgency.GetHashCode().ToString();
                    form["PropertyInfo.PrivateLandlordAgency.Id"] = form["PropertyInfo.Agency.Id"];
                }
                if (Int32.Parse(form["PropertyInfo.JobType"].ToString()) != (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged)
                {
                    form["PropertyInfo.Agency.Id"] = model.PrivateLandlordsAgencyId.ToString();
                }
                if (Int32.Parse(form["PropertyInfo.JobType"].ToString()) == (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.PrivateLandlordNoAgency)
                {
                    form["PropertyInfo.PrivateLandlordAgency.Id"] = model.PrivateLandlordsAgencyId.ToString();
                    form["PropertyInfo.PrivateLandlordBillTo"] = DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.PrivateLandlordBillToTypeEnum.BillToLandlord.GetHashCode().ToString();
                }

                var existingAgencyId = -1;
                if (model.PropertyInfo != null && model.PropertyInfo.Agency != null)
                {
                    existingAgencyId = model.PropertyInfo.Agency.Id;
                }
                var existingKeyNumber = model.PropertyInfo.KeyNumber;


                bool previousIsReactivatedState = model.PropertyInfo.IsReactivated;

                if (TryUpdateModel(model, "", null, new[] { "PropertyInfo.Id" }, form.ToValueProvider()))
                {
                    if (model.PropertyInfo.IsCancelled && model.PropertyInfo.CancellationNotes == null)
                    {
                        //   ShowValidationErrorMessage("Duplicate", "Property is Already Exists");
                        return View(model);
                    }
                    if (model.PropertyInfo.IsReactivated == true)
                    {
                        if (model.PropertyInfo.ReactivationNotes == null)
                        {
                            ShowValidationErrorMessage("ReactivationNotes", "Reactivation Notes are required for a re-activated Property");
                            return View(model);
                        }
                    }
                    /// Code Added By Arun
                    var existingPropertyResults = _propertyRepository.FindByAddress(model.PropertyInfo.UnitShopNumber,
                                                            model.PropertyInfo.StreetNumber,
                                                            model.PropertyInfo.StreetName,
                                                            model.PropertyInfo.Suburb,
                                                            model.PropertyInfo.PostCode,
                                                            model.PropertyInfo.State);
                    if (existingPropertyResults != null && existingPropertyResults.Count() == 1)
                    {
                        // ShowValidationErrorMessage("CancellationNotes", "Cancellation Notes are required for a cancelled Property");
                        ShowValidationErrorMessage("Duplicate", "Property is Already Exists");
                        return View(model);
                    }
                    if (model.PropertyInfo.Zone == null)
                    {
                        var itemCount = 0;
                        var pageCount = 0;
                        var suburb = (from s in Repository.GetAll<Suburb>("Name", System.ComponentModel.ListSortDirection.Ascending, out itemCount, out pageCount)
                                      where s.Name.ToLower().Equals(model.PropertyInfo.Suburb.ToLower())
                                      select s).FirstOrDefault();

                        if (suburb != null)
                        {
                            model.PropertyInfo.Zone = suburb.Zone;
                        }
                        else
                        {
                            ShowValidationErrorMessage("Suburb", "Suburb could not be located");
                            return View(model);
                        }
                    }
                    // OLD code. The discount is now applied when an invoice is created (in this file) or in BatchViewModel.cs for the quotation
                    // RJC 20130314. Zone must now be defined, so we can get the price info
                    //                    var zoneCharge = GetPropertyZoneCharge(model.PropertyInfo);
                    //					model.PropertyInfo.Discount = zoneCharge * model.PropertyInfo.DiscountPercentage / 100;

                    var hasChangedAgency = false;
                    if (model.PropertyInfo.Agency != null)
                    {
                        hasChangedAgency = existingAgencyId != model.PropertyInfo.Agency.Id;
                    }

                    model.UpdateModel(hasChangedAgency, previousIsReactivatedState != model.PropertyInfo.IsReactivated);
                    Repository.Save(model.PropertyInfo);

                    var keyNumberChanged = existingKeyNumber != model.PropertyInfo.KeyNumber;

                    try
                    {
                        tx.Commit();

                        // Need to wait for changes to the PropertyInfo session to be committed before we can update the booking record.
                        if (keyNumberChanged)
                        {
                            // work-around to sync changes to the KeyNumber to the copy of the key number in the Booking table
                            _bookingRepository.UpdateKeyNumberOnLastBooking(model.PropertyInfo.Id, model.PropertyInfo.KeyNumber);
                        }

                        ShowInfoMessage("Success", "Property saved.");
                        TempData["DialogValue"] = "property-search";

                        if (JsWindowHelper.IsWindowToClose(this.ControllerContext))
                        {
                            TempData["CloseDialog"] = "true";
                        }
                        else
                        {
                            TempData["CloseDialog"] = "false";
                        }

                        return new ApplySaveResult("View", new { id = model.PropertyInfo.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Property"));

                        return View(model);
                    }
                }
                else
                {
                    return View(model);
                }
            }
        }

        private decimal GetPropertyZoneCharge(Model.PropertyInfo propInfo)
        {
            // RJC. 20130313. Code base on code from BatchViewModel.cs
            var zoneCharge = 0.0m;
            switch (propInfo.Zone.Id)
            {
                case 1:
                    zoneCharge = Repository.Get<ServiceItem>((int)SystemServiceItem.Zone1).Price;
                    break;
                case 2:
                    zoneCharge = Repository.Get<ServiceItem>((int)SystemServiceItem.Zone2).Price;
                    break;
                default:
                    zoneCharge = Repository.Get<ServiceItem>((int)SystemServiceItem.Zone3).Price;
                    break;
            }
            return zoneCharge;
        }

        [HttpGet]
        [Transactional]
        public ActionResult Booking(int id)
        {
            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, false, _agencyRepository);

            return View(model);
        }

        [HttpGet]
        [Transactional]
        public ActionResult ServiceSheet(int id)
        {
            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, false, _agencyRepository);

            return View(model);
        }

        [HttpGet]
        [Transactional]
        public ActionResult Landlord(int id)
        {
            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, true, _agencyRepository);

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Landlord(int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Property"))
            {
                var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, true, _agencyRepository);

                if (TryUpdateModel(model, "", null, new[] { "PropertyInfo.Id" }, form.ToValueProvider()))
                {

                    model.UpdateModel(false);
                    Repository.Save(model.PropertyInfo);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Property saved.");


                        if (JsWindowHelper.IsWindowToClose(this.ControllerContext))
                        {
                            TempData["DialogValue"] = "property-search";
                            TempData["CloseDialog"] = "true";
                        }
                        else
                        {
                            TempData["DialogValue"] = "property-search";
                            TempData["CloseDialog"] = "false";
                        }

                        return new ApplySaveResult("Landlord", new { id = model.PropertyInfo.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Property"));

                        return View(model);
                    }
                }
                else
                {
                    return View(model);
                }
            }
        }



        [HttpGet]
        [Transactional]
        public ActionResult EditDetector(int propertyInfoId, int id)
        {
            var model = new DetectorViewModel(Repository, _propertyRepository.Get(propertyInfoId), id);

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditDetector(int propertyInfoId, int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Detector"))
            {
                var parent = _propertyRepository.Get(propertyInfoId);
                var model = new DetectorViewModel(Repository, parent, id);

                if (TryUpdateModel(model, "", null, new[] { "Detector.Id" }, form.ToValueProvider()))
                {

                    parent.AddDetector(model.Detector);
                    Repository.Save(model.Detector);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Detector saved.");
                        TempData["IsValid"] = true;
                        return View(model);
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Detector"));

                        return View(model);
                    }
                }
                else
                {
                    return View(model);
                }
            }
        }


        [HttpPost]
        [Transactional]
        public ActionResult GetDetectorItems(int propertyInfoId, string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            int itemCount;
            int pageCount;

            var propertyInfo = _propertyRepository.Get(propertyInfoId);

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = propertyInfo.ActiveDetectors.GetPage(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

            var result = new
            {
                pageCount = pageCount,
                pageNumber = pageNumber,
                itemCount = itemCount,
                items = (
                    from item in items
                    select new
                    {
                        id = item.Id.ToString(),
                        rowVersion = Convert.ToBase64String(item.RowVersion),
                        expiryYear = item.ExpiryYear.ToString(),
                        detectorType = HttpUtility.HtmlEncode(item.DetectorType.Name),
                        location = HttpUtility.HtmlEncode(item.Location),
                        manufacturer = HttpUtility.HtmlEncode(item.Manufacturer),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted),
                        isOptional = StringFormatter.BooleanToYesNo(item.IsOptional)
                    }).ToArray()
            };

            return Json(result);
        }

        [HttpPost]
        public ActionResult ContactNotes(int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Edit Contact Notes"))
            {
                var model = Repository.Get<DetectorInspector.Model.PropertyInfo>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion", "ContactNotes" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        Repository.Save(model);

                        tx.Commit();

                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Update Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Property"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Property not updated",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Property"));
                    }
                }
            }
            return Json(new { success = true });
        }



        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Property"))
            {
                var model = Repository.Get<DetectorInspector.Model.PropertyInfo>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        model.IsDeleted = true;
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Property deleted.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Property"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Property not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Property"));
                    }
                }
            }

            return RedirectToAction("Index");
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteDetector(int propertyInfoId, int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Detector"))
            {
                var parent = _propertyRepository.Get(propertyInfoId);
                var model = Repository.Get<DetectorInspector.Model.Detector>(id);
                parent.RemoveDetector(model);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Detector deleted.");
                        return Json(new { success = true });
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Detector"));
                        return Json(new { success = false });
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Detector not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Detector"));
                        return Json(new { success = false });
                    }
                }
                else
                {
                    return Json(new { success = false });
                }
            }

        }
        // Code Added By Arun From Export Inspection Invoice and show Message after invoice download
        //public ActionResult PerformBulkActionE(BulkAction bulkAction, IEnumerable<int> selectedRows, InspectionStatus? inspectionStatus, ElectricalWorkStatus? electricalWorkStatus, decimal? discount, string notes, DateTime? notificationDate, FormCollection form)
        //{
        //    var model = new BulkActionViewModel();
        //    var userProfile = User.Identity.GetProfile();
        //    string files = "";
        //    if (bulkAction.Equals(BulkAction.ExportMobileNumberForSMS))
        //    {
        //        if (TryUpdateModel(model, form.ToValueProvider()))
        //        {
        //            return ExportMobileNumberForSMS(model.notificationDate.Value);
        //        }
        //    }
        //    if (selectedRows == null)
        //    {
        //        return Json(new { success = false, message = "No rows selected" });
        //    }
        //    if (TryUpdateModel(model, form.ToValueProvider()))
        //    {
        //        _propertyRepository.UpdateInspectionStatus(model.selectedRows, inspectionStatus.Value, User.Identity.GetUserId().Value);
        //        var propertyBatch = new PropertyBatch();
        //        using (var tx = TransactionFactory.BeginTransaction("Create Inspection Invoice"))
        //        {
        //            propertyBatch.BulkActionId = (int)BulkAction.ExportInspectionInvoice;
        //            propertyBatch.StatusId = (int)inspectionStatus.Value;
        //            propertyBatch.Date = model.notificationDate.Value;
        //            foreach (var rowId in selectedRows)
        //            {
        //                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
        //            }
        //            Repository.Save(propertyBatch);
        //            tx.Commit();
        //        }
        //        files = ExportInspectionInvoice(propertyBatch);
        //        //  FileStreamResult s = ExportInspectionInvoice(propertyBatch, ref c);
        //        //  return Json.ToString();
        //        //  return Json(new { success = true, message = "Batch number is " + propertyBatch.Id.ToString() });
        //        string InvoiceMessage = string.Empty;
        //    }
        //    return Json(new { success = true, file = files, InvoiceMessage = Session["Message"] });
        //}



        //public ActionResult PerformBulkActionE(BulkAction bulkAction, IEnumerable<int> selectedRows, InspectionStatus? inspectionStatus, ElectricalWorkStatus? electricalWorkStatus, decimal? discount, string notes, DateTime? notificationDate, FormCollection form)
        //{
        //    var model = new BulkActionViewModel();
        //    var userProfile = User.Identity.GetProfile();
        //    string files = "";
        //    if (bulkAction.Equals(BulkAction.ExportMobileNumberForSMS))
        //    {
        //        if (TryUpdateModel(model, form.ToValueProvider()))
        //        {
        //            return ExportMobileNumberForSMS(model.notificationDate.Value);
        //        }
        //    }
        //    if (selectedRows == null)
        //    {
        //        return Json(new { success = false, message = "No rows selected" });
        //    }
        //    if (TryUpdateModel(model, form.ToValueProvider()))
        //    {
        //        _propertyRepository.UpdateInspectionStatus(model.selectedRows, inspectionStatus.Value, User.Identity.GetUserId().Value);
        //        var propertyBatch = new PropertyBatch();
        //        using (var tx = TransactionFactory.BeginTransaction("Create Inspection Invoice"))
        //        {
        //            propertyBatch.BulkActionId = (int)BulkAction.ExportInspectionInvoice;
        //            propertyBatch.StatusId = (int)inspectionStatus.Value;
        //            propertyBatch.Date = model.notificationDate.Value;
        //            foreach (var rowId in selectedRows)
        //            {
        //                propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
        //            }
        //            Repository.Save(propertyBatch);
        //            tx.Commit();
        //        }
        //      //  files = ExportInspectionInvoice(propertyBatch);
        //        FileStreamResult s = ExportInspectionInvoice(propertyBatch);
        //        //  return Json.ToString();
        //        //  return Json(new { success = true, message = "Batch number is " + propertyBatch.Id.ToString() });
        //        string InvoiceMessage = string.Empty;
        //    }
        //    return Json(new { success = true, file = files, InvoiceMessage = Session["Message"] });
        //}

        private string ExportInspectionInvoice(PropertyBatch propertyBatch)
        //  private string ExportInspectionInvoice(PropertyBatch propertyBatch)
        //    private FileStreamResult ExportInspectionInvoice(PropertyBatch propertyBatch, ref int c)
        //    private Array ExportInspectionInvoice(PropertyBatch propertyBatch)
        {
            //var discount = Repository.Get<ServiceItem>((int)SystemServiceItem.Discount);
            //   c = 10;
            var invoiceExport = new InvoiceExport();
            // Code change by Arun
            //  ArrayList arrlist = new ArrayList();
            //  Session["Message"] = "";


            using (var tx = TransactionFactory.BeginTransaction("Create Inspection Invoice"))
            {
                foreach (var item in propertyBatch.PropertyInfo)
                {
                    item.UpdateExpiryYears();

                    Repository.Save(item);

                    var isInvoiced = false;
                    decimal discount = 0;

                    if (item.Agency.Discount > 0)
                    {
                        discount = item.Agency.Discount;
                    }


                    bool isFixedFeeService = item.IsFixedFeeService;

                    if (item.Agency != null)
                    {
                        isFixedFeeService |= (item.Agency.IsFixedFeeService == true);
                    }

                    if (item.PropertyManager != null)
                    {
                        isFixedFeeService |= (item.PropertyManager.IsFixedFeeService == true);
                    }

                    if (isFixedFeeService)
                    {
                        var lineItems = new List<InvoiceTransactionLineItem>();
                        var fixedFeeServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.FixedFeeService);
                        string fixedFeeServiceDetails = GetBookingItemDescriptions(item.ActiveBookings);


                        IEnumerable<DetectorInspector.Model.Booking> bookings = from b in item.ActiveBookings
                                                                                where b.IsInvoiced.Equals(false)
                                                                                orderby b.Date descending
                                                                                select b;
                        DetectorInspector.Model.Booking currentBooking = null;
                        // get first in list is there is anything in the list 
                        foreach (var booking in bookings)
                        {
                            currentBooking = booking;
                            break;
                        }

                        lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, fixedFeeServiceItem, 1, discount, fixedFeeServiceDetails));

                        if (item.DiscountPercentage != 0)
                        {
                            ServiceItem discountLineItem = Repository.Get<ServiceItem>((int)SystemServiceItem.ServiceFeeDiscount);// RJC. Apparently ServiceFeeDiscount is actually property discount !!
                            discountLineItem.Price = -1 * (fixedFeeServiceItem.Price - discount) * (item.DiscountPercentage / 100);// property discount % is taken on full price less Agency discount ($)
                            lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, discountLineItem, 1, 0, discountLineItem.QuickBooksFreeAndFixedFeeDescription));
                        }
                        //add the transaction
                        invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

                        currentBooking.IsInvoiced = true;
                        Repository.Save<Model.Booking>(currentBooking);
                    }
                    else
                    {
                        if (item.IsFreeService == true)
                        {
                            var lineItems = new List<InvoiceTransactionLineItem>();
                            var fixedFeeServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.FreeService);
                            string freeServiceDetails = GetBookingItemDescriptions(item.ActiveBookings);

                            IEnumerable<DetectorInspector.Model.Booking> bookings = from b in item.ActiveBookings
                                                                                    where b.IsInvoiced.Equals(false)
                                                                                    orderby b.Date descending
                                                                                    select b;
                            DetectorInspector.Model.Booking currentBooking = null;
                            // get first in list is there is anything in the list 
                            foreach (var booking in bookings)
                            {
                                currentBooking = booking;
                                break;
                            }

                            lineItems.Add(QuickBooksDataUtil.GetAppendedLineItem(propertyBatch, currentBooking, fixedFeeServiceItem, 1, 0, freeServiceDetails));
                            //add the transaction
                            invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

                            currentBooking.IsInvoiced = true;
                            Repository.Save<Model.Booking>(currentBooking);
                        }
                        else
                        {

                            if (item.ElectricalWorkStatus.Equals(ElectricalWorkStatus.ElectricalApprovalRejected))
                            {

                                SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Default"].ConnectionString);
                                using (var cmd = new SqlCommand("p_PropertyBatchItemAutomaticTable_GetItems", (SqlConnection)conn))
                                {
                                    cmd.CommandType = CommandType.StoredProcedure;
                                    cmd.Parameters.AddWithValue("@PropertyInfo", item.Id);
                                    if (conn.State == ConnectionState.Closed)
                                    {
                                        conn.Open();
                                    }
                                    using (var dr = cmd.ExecuteReader())
                                    {
                                        //  while (dr.Read())
                                        dr.Read();
                                        {
                                            // var PropertyId;
                                            if (dr.HasRows == true)
                                            {
                                                //  var PId = dr.GetInt32("PropertyInfo");
                                                //    PropertyId = PropertyId + "," + PId;
                                                //  PIdetail = item.StreetNumber + item.StreetName + item.Suburb + item.State.Name;
                                                if (Propertydetails == null)
                                                {
                                                    Propertydetails = item.StreetNumber + " " + item.StreetName + " " + item.Suburb + " " + item.State.Name;
                                                }
                                                else
                                                {
                                                    Propertydetails = Propertydetails + " " + ", " + item.StreetNumber + " " + item.StreetName + " " + item.Suburb + " " + item.State.Name;
                                                    //   item.Propertydetails = Propertydetails;
                                                    break;
                                                }

                                            }

                                            else
                                            {




                                                var electricalCallout = Repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalCallOut);
                                                var lineItems = new List<InvoiceTransactionLineItem>();

                                                lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, null, electricalCallout, 1, discount));

                                                invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, null, item));

                                                isInvoiced = true;

                                                item.Cancel(ElectricalWorkStatus.ElectricalApprovalRejected.GetDescription());
                                            }
                                        }
                                    }
                                }
                            }

                            var bookings = from b in item.ActiveBookings
                                           where b.IsInvoiced.Equals(false)
                                           select b;
                            foreach (var booking in bookings)
                            {

                                var lineItems = new List<InvoiceTransactionLineItem>();

                                if (!isInvoiced)
                                {
                                    if (booking.ServiceSheet != null)
                                    {
                                        //discount = discount + booking.ServiceSheet.Discount;
                                        //if the service sheet is electrical, we need to invoice for the detectors, electrical service and the certificate
                                        //we may also need to invoice for non electrical items as well
                                        if (booking.ServiceSheet.IsElectrical)
                                        {


                                            var detectorCount = QuickBooksDataUtil.GetElectricalDetectorCountMainsOrSecurity(booking);

                                            var detectorServiceItem = QuickBooksDataUtil.GetServiceItem(booking, Repository, detectorCount);

                                            var certificateServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.Certificate);

                                            var smokeDetectorServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector);

                                            decimal discnt = detectorServiceItem.Price * booking.PropertyInfo.DiscountPercentage / 100;

                                            booking.PropertyInfo.Discount = decimal.Round(discnt, 2);// rjc. 20130319 Hack to use property % discount on electrical service items, as requested by Jason.
                                            //electrical service
                                            lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, detectorServiceItem, 1, discount));


                                            // mains detector (not security mains)
                                            var mainsDetectorCount = QuickBooksDataUtil.GetElectricalDetectorCountMains(booking);

                                            if (mainsDetectorCount > 0)
                                            {
                                                var electricalServiceServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalMainDetector);
                                                lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, electricalServiceServiceItem, mainsDetectorCount, 0));
                                            }

                                            // mains detector (not security mains)
                                            var securityDetectorCount = QuickBooksDataUtil.GetElectricalDetectorCountSecurity(booking);

                                            if (securityDetectorCount > 0)
                                            {
                                                var electricalServiceServiceItemSecurity = Repository.Get<ServiceItem>((int)SystemServiceItem.SecurityDetector);
                                                lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, electricalServiceServiceItemSecurity, securityDetectorCount, 0));
                                            }
                                            //certificate
                                            lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, certificateServiceItem, 1, 0));

                                            var replacedServiceItemCount = QuickBooksDataUtil.GetReplacedServiceItemWithoutMainsCount(booking);

                                            if (replacedServiceItemCount > 0)
                                            {
                                                lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, smokeDetectorServiceItem, replacedServiceItemCount, 0));
                                            }

                                            //add the transaction
                                            invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, booking, item));
                                        }
                                        else
                                        {
                                            var serviceItem = QuickBooksDataUtil.GetServiceItem(booking, Repository, 0);
                                            var smokeDetectorServiceItem = Repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector);


                                            // rjc 20130403
                                            var zoneCharge = GetPropertyZoneCharge(booking.PropertyInfo);
                                            decimal discnt = (zoneCharge - discount) * booking.PropertyInfo.DiscountPercentage / 100;
                                            booking.PropertyInfo.Discount = decimal.Round(discnt, 2);

                                            // Non Electrical Items
                                            lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, serviceItem, 1, discount));

                                            var replacedServiceItemCount = QuickBooksDataUtil.GetReplacedServiceItemCount(booking);

                                            if (replacedServiceItemCount > 0)
                                            {
                                                lineItems.Add(QuickBooksDataUtil.GetLineItem(propertyBatch, booking, smokeDetectorServiceItem, replacedServiceItemCount, 0));
                                            }

                                            invoiceExport.InvoiceTransactions.Add(QuickBooksDataUtil.GetTransaction(lineItems, Repository, propertyBatch, booking, item));
                                        }


                                    }
                                }


                                booking.IsInvoiced = true;
                                Repository.Save<Model.Booking>(booking);
                            }
                        }// Not fixed fee service
                    }

                    if (item.IsOneOffService)
                    {
                        item.Cancel("Once off service");
                    }

                    item.ContactNotes = "";// RJC 20130314 - Issue 2 from Jason's list, erase contact notes when item is invoiced.
                    Repository.Save(item);// Now save the changes
                } // foreach
                tx.Commit();


            }// using....

            string iifStr = invoiceExport.ToString();
            var bytes = Encoding.GetEncoding("iso-8859-1").GetBytes(iifStr);
            //   var bytes = Encoding.GetEncoding("utf-8").GetBytes(invoiceExport.ToString());// To Do need to encode wider rang of chars, possible use windows char set 12xx
            var stream = new MemoryStream(bytes);

            //  var fileiif = File(stream, "text/csv", "invoice.iif");
            //arrlist.Add(fileiif);
            //PropertydetailMessage = Propertydetails + "Invoices for these properties have not be generated as they are from Electrician Required (Automatic): then list the properties";
            //arrlist.Add(PropertydetailMessage);

            //  string BackBtnVal = Convert.ToString(Request["hidBack"]);
            //  .ClientScript.RegisterStartupScript(this.GetType(), "BckBtn", "document.getElementById('hidBck').value = '" + BackBtnVal + "';", true);

            //   lblKeyword.Text = "";
            //foreach (var item in propertyBatch.PropertyInfo)
            //{
            //    item.Propertydetails = PropertydetailMessage;
            //}
            // ViewData["Message"] = PropertydetailMessage;
            if (Propertydetails != null)
            {
                Session["Message"] = "Invoices for these properties have not be generated as they are from Electrician Required (Automatic): " + Propertydetails;
            }
            //  return invoiceExport.ToString();

            // var model = new Model.PropertyInfoSearchResult();
            //  model.Prop = "window.alert(' this is from action');";
            //var model123 = new PropertyInfoSearchViewModel(Repository, false, true);
            //model123.R = "window.alert(' this is from action');";

            //  UpdateMessage();
            // TempData["Update"] = "aaa";
            // ViewData["Message"] = "text";
            //for (int i = 0; i < arrlist.Count; i++)
            //{
            //    // return File(arrlist[i].ToString() + "<br />");
            //return File(strem, "text/csv", "invoice.iif");
            //}
            // ViewData.Values = @"<script type='text/javascript' language='javascript'>alert(""Hello World!"")</script>"; ;
            //ViewBag.message = @"<script type='text/javascript' language='javascript'>alert(""Hello World!"")</script>"; ;
            //     return JavaScript("Callback()");
            //   return stream.ToString();
            // return File(stream, "text/csv", "invoice.iif");


            string savedFileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Invoice");
            savedFileName = Path.Combine(savedFileName, "Invoice.iif");
            try
            {
                System.IO.File.WriteAllText(savedFileName, iifStr, Encoding.GetEncoding("iso-8859-1"));

            }
            catch
            {
                // return string(new { success = false, message = "Error saving approval file" });
            }
            // return savefile;
            // return invoiceExport.ToString();
            //return HttpUtility.UrlEncode(savedFileName);
            // string path = "localhost:61074/invoice/invoice.iif";
          
            string path = "invoice/invoice.iif";
            return path;
            //   return savedFileName;
        }





        public ActionResult PerformBulkActionSecond(BulkAction bulkAction, IEnumerable<int> selectedRows, InspectionStatus? inspectionStatus, ElectricalWorkStatus? electricalWorkStatus, decimal? discount, string notes, DateTime? notificationDate, FormCollection form)
        {
            var model = new BulkActionViewModel();
            var userProfile = User.Identity.GetProfile();
            string files = "";
            if (bulkAction.Equals(BulkAction.ExportMobileNumberForSMS))
            {
                if (TryUpdateModel(model, form.ToValueProvider()))
                {
                    return ExportMobileNumberForSMS(model.notificationDate.Value);
                }
            }
            if (selectedRows == null)
            {
                return Json(new { success = false, message = "No rows selected" });
            }
            if (TryUpdateModel(model, form.ToValueProvider()))
            {
                _propertyRepository.UpdateInspectionStatus(model.selectedRows, inspectionStatus.Value, User.Identity.GetUserId().Value);
                var propertyBatch = new PropertyBatch();
                using (var tx = TransactionFactory.BeginTransaction("Create Inspection Invoice"))
                {
                    propertyBatch.BulkActionId = (int)BulkAction.ExportInspectionInvoice;
                    propertyBatch.StatusId = (int)inspectionStatus.Value;
                    propertyBatch.Date = model.notificationDate.Value;
                    foreach (var rowId in selectedRows)
                    {
                        propertyBatch.AddPropertyInfo(Repository.GetReference<Model.PropertyInfo>(rowId));
                    }
                    Repository.Save(propertyBatch);
                    tx.Commit();
                }
                files = ExportInspectionInvoice(propertyBatch);
                //  FileStreamResult s = ExportInspectionInvoice(propertyBatch);
                //  return Json.ToString();
                //  return Json(new { success = true, message = "Batch number is " + propertyBatch.Id.ToString() });
                string InvoiceMessage = string.Empty;
            }
            return Json(new { success = true, file = files, InvoiceMessage = Session["Message"] });
        }
    }
}