using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DetectorInspector.Areas.Agency.ViewModels;
using DetectorInspector.Controllers;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using Kiandra.Data;
using Kiandra.Web.Mvc;
using System.IO;

namespace DetectorInspector.Areas.Agency.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AccessAgencies)]
    public class HomeController : SiteController
    {
        private readonly IAgencyRepository _agencyRepository;

        public HomeController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IAgencyRepository agencyRepository,
            IPropertyRepository propertyRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _agencyRepository = agencyRepository;
        }

        [HttpGet]
        public ActionResult Index()
        {
            //if (SecurityExtensions.HasPermission == true)
            //{

            //}
            return View(new AgencyTotalsViewModel { ActivePropertiesTotal = _agencyRepository.GetActivePropertiesTotal(), PropertiesTotal = _agencyRepository.GetPropertiesTotal() });
        }
        [HttpPost]
        [Transactional]
        public ActionResult GetItems(string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            int itemCount;
            int pageCount;
            var listSortDirection =
      string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;
            var items = Repository.GetActive<DetectorInspector.Model.Agency>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);
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
              name = HttpUtility.HtmlEncode(item.Name),
              agencyGroup = HttpUtility.HtmlEncode(item.AgencyGroup.Name),
              activeCount = item.ActiveProperties.Count(p => p.IsCancelled.Equals(false)),
              propertyCount = item.ActiveProperties.Count(),
              privateCount = item.ActivePrivateLandlordProperties.Count(),
              isCancelled = StringFormatter.BooleanToYesNo(item.IsCancelled),
              isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
          }).ToArray()
  };

            return Json(result);
        }

        [HttpPost]
        public ActionResult AgencySuperUser()
        {
            //    return View();
            return View(new AgencyTotalsViewModel { ActivePropertiesTotal = _agencyRepository.GetActivePropertiesTotal(), PropertiesTotal = _agencyRepository.GetPropertiesTotal() });
        }
        [HttpPost]
        [Transactional]
        public ActionResult GetItemsSuper(string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            int itemCount;
            int pageCount;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = Repository.GetActive<DetectorInspector.Model.Agency>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        name = HttpUtility.HtmlEncode(item.Name),
                        agencyGroup = HttpUtility.HtmlEncode(item.AgencyGroup.Name),
                        //activeCount = item.ActiveProperties.Count(p => p.IsCancelled.Equals(false)),
                        //propertyCount = item.ActiveProperties.Count(),
                        //privateCount = item.ActivePrivateLandlordProperties.Count(),
                        isCancelled = StringFormatter.BooleanToYesNo(item.IsCancelled),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
                    }).ToArray()
            };

            return Json(result);
        }


        [HttpGet]
        [Transactional]
        public ActionResult Edit(int id)
        {
            var model = new AgencyViewModel(Repository, _agencyRepository, id);

            return View(model);
        }


        [HttpGet]
        public FileStreamResult DownloadEntryNotification(int id)
        {
            var model = new AgencyViewModel(Repository, _agencyRepository, id);

            string savedFileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EntryNotificationLetterTemplates");
            savedFileName = Path.Combine(savedFileName, id.ToString() + ".docx");
            var f = new FileStream(savedFileName, FileMode.OpenOrCreate);

            return File(f, "application/msword", "Entry Notification - Agency Letter -" + model.Agency.Name + ".docx");
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";
            string messageTitle = "", messageBody = "";

            //if (form["importButton"]=="Import")
            {

                var hpf = this.Request.Files["EntryNotificationLetterFile"];
                if (hpf.ContentLength != 0)
                {
                    string savedFileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EntryNotificationLetterTemplates");
                    savedFileName = Path.Combine(savedFileName, id.ToString() + ".docx");
                    try
                    {
                        hpf.SaveAs(savedFileName);
                        messageTitle = "Success";
                        messageBody = "File has been saved.";
                    }
                    catch
                    {
                        messageTitle = "Error";
                        messageBody = "File could not be saved.";

                    }
                }


                //var model = new AgencyViewModel(Repository, _agencyRepository, id);
                //return View(model);
            }



            using (var tx = TransactionFactory.BeginTransaction(action + " Agency"))
            {
                var model = new AgencyViewModel(Repository, _agencyRepository, id);

                if (isCreated)
                {
                    if (form["Agency.CustomerCode"].Length > 3)
                    {
                        ShowErrorMessage("Save Failed", "Agency code can only be a maximum of 3 characters long");

                        return View(model);
                    }
                }
                else
                {
                    if (model.Agency.CustomerCode.Length <= 3 && form["Agency.CustomerCode"].Length > 3)
                    {
                        ShowErrorMessage("Save Failed", "Agency code can only be a maximum of 3 characters long");

                        return View(model);
                    }
                }

                if (TryUpdateModel(model, "", null, new[] { "Agency.Id" }, form.ToValueProvider()))
                {

                    if (isCreated)
                    {
                        if (form["Agency.CustomerCode"].Length > 3)
                        {
                            ShowErrorMessage("Save Failed", "Agency code can only be a maximum of 3 characters long");

                            return View(model);
                        }
                    }
                    else
                    {
                        if (model.Agency.CustomerCode.Length <= 3 && form["Agency.CustomerCode"].Length > 3)
                        {
                            ShowErrorMessage("Save Failed", "Agency code can only be a maximum of 3 characters long");

                            return View(model);
                        }
                    }

                    if (Repository.IsNameInUse<DetectorInspector.Model.Agency>(model.Agency.Name, id))
                    {
                        ShowValidationErrorMessage("Name",
                            string.Format(SR.Unique_Property_Violation_Message, "Name"));

                        return View(model);
                    }

                    if (Repository.IsCustomerCodeInUse<DetectorInspector.Model.Agency>(model.Agency.CustomerCode, id))
                    {
                        ShowValidationErrorMessage("Customer Code",
                            string.Format(SR.Unique_Property_Violation_Message, "Customer Code"));

                        return View(model);
                    }

                    Repository.Save(model.Agency);

                    try
                    {
                        tx.Commit();
                        if (messageBody == "")
                        {
                            ShowInfoMessage("Success", "Agency saved.");
                        }
                        else
                        {
                            ShowInfoMessage(messageTitle, messageBody);
                        }
                        return new ApplySaveResult("Edit", new { id = model.Agency.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Agency"));

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
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Agency"))
            {
                var model = Repository.Get<DetectorInspector.Model.Agency>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        model.IsDeleted = true;
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Agency deleted.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Agency"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Agency not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Agency"));
                    }
                }
            }

            return RedirectToAction("Index");
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Cancel(int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Cancel Agency"))
            {
                var model = Repository.Get<DetectorInspector.Model.Agency>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {

                        model.Cancel();
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Agency cancelled.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Cancel Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Agency"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Agency not cancelled",
                            string.Format(SR.EntityInUseException_Delete_Message, "Agency"));
                    }
                }
            }

            return RedirectToAction("Index");
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetPropertyManagersForAgency(int? agencyId, int propertyInfoId)
        {
            PropertyManager propertyManager = null;

            if (propertyInfoId != 0)
            {
                var propertyInfo = Repository.Get<DetectorInspector.Model.PropertyInfo>(propertyInfoId);
                if (propertyInfo.PropertyManager != null)
                {
                    propertyManager = propertyInfo.PropertyManager;
                }
            }

            return Json(GetPropertyManagersForAgencyAsList(propertyManager, agencyId));
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetPropertyManagersForPrivateLandlordAgency(int? agencyId, int propertyInfoId)
        {
            PropertyManager propertyManager = null;

            if (propertyInfoId != 0)
            {
                var propertyInfo = Repository.Get<DetectorInspector.Model.PropertyInfo>(propertyInfoId);
                if (propertyInfo.PropertyManager != null)
                {
                    propertyManager = propertyInfo.PrivateLandlordPropertyManager;
                }
            }

            return Json(GetPropertyManagersForAgencyAsList(propertyManager, agencyId));
        }


        internal IEnumerable<SelectListItem> GetPropertyManagersForAgencyAsList(PropertyManager propertyManager, int? agencyId)
        {
            IList<SelectListItem> result = new List<SelectListItem>();
            DetectorInspector.Model.Agency agency;
            if (agencyId.HasValue)
            {
                agency = _agencyRepository.Get(agencyId.Value);
                result =
                    (from item in agency.ActivePropertyManagers
                     select new SelectListItem
                     {
                         Value = item.Id.ToString(),
                         Text = HttpUtility.HtmlEncode(item.Name),
                         Selected = item.Equals(propertyManager)
                     }).ToList();
            }

            if (propertyManager != null && !(result.Count(item => item.Value.Equals(propertyManager.Id.ToString())) > 0))
            {
                var item = new SelectListItem()
                {
                    Value = propertyManager.Id.ToString(),
                    Text = propertyManager.Name,
                    Selected = true
                };

                result.Insert(0, item);
            }

            var a = new SelectListItem() { Value = "", Text = "-- Please select --" };
            result.Insert(0, a);

            return result;
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ExportProperties(int id)
        {

            DbExportContext context = new DbExportContext(ExportFormat.Xls);
            var command = context.GetCommand("p_PropertyInfo__Agency", CommandType.StoredProcedure);
            command.Parameters.Add(context.GetParameter("@agencyId", id));
            var stream = context.Export(command, "Sheet1");
            return File(stream, "application/vnd.ms-excel", "property-export.xls");
        }

    }
}