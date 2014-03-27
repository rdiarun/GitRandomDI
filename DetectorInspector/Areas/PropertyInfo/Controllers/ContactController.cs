using System;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using Kiandra.Data;
using Kiandra.Web.Mvc;

using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using DetectorInspector.Controllers;
using DetectorInspector.Areas.PropertyInfo.ViewModels;

namespace DetectorInspector.Areas.PropertyInfo.Controllers
{
    [HandleError]
    //[RequirePermission(Permission.AdministerSystem)]
    public class ContactController : SiteController
    {
        IPropertyRepository _propertyRepository;
        IAgencyRepository _agencyRepository;

        public ContactController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IPropertyRepository propertyRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository,
            IAgencyRepository agencyRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _propertyRepository = propertyRepository;
            _agencyRepository = agencyRepository;
        }

        [HttpGet]
        public ActionResult Index(int id)
        {

            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, true, _agencyRepository);

            return View(model);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Index(int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Property"))
            {
                var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, true, _agencyRepository);

                if (TryUpdateModel(model, "", null, new[] { "PropertyInfo.Id" }, form.ToValueProvider()))
                {
                    model.PropertyInfo.ApplyUpdatedContactDetails();

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

                        return new ApplySaveResult("Index", new { area = "PropertyInfo", id = model.PropertyInfo.Id }, "Index", "Home", new { area = "PropertyInfo", id = model.PropertyInfo.Id });
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

        [HttpPost]
        [Transactional]
        public ActionResult GetItems(int propertyInfoId, string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            var model = _propertyRepository.Get(propertyInfoId);

            int itemCount;
            int pageCount;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = model.ActiveContactEntries.GetPage(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        contactNumber = HttpUtility.HtmlEncode(item.ContactNumber),
                        contactNumberType = HttpUtility.HtmlEncode(item.ContactNumberType.Name),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
                    }).ToArray()
            };

            return Json(result);
        }

        [HttpGet]        
        [Transactional]
        public ActionResult Edit(int propertyInfoId, int id)
        {
            var model = new ContactEntryViewModel(Repository, _propertyRepository.Get(propertyInfoId), id);

            return View(model);
        }

        [HttpPost]        
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int propertyInfoId, int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Tenant"))
            {
                var parent = _propertyRepository.Get(propertyInfoId);
                var model = new ContactEntryViewModel(Repository, parent, id);

                if (TryUpdateModel(model, "", null, new[] { "PropertyInfo.Id" }, form.ToValueProvider()))
				{
                    parent.ApplyUpdatedContactDetails();
                    parent.AddContactEntry(model.ContactEntry);
                    model.ContactEntry.IsDeleted = false;

                    Repository.Save(model.ContactEntry);
                    Repository.Save(parent);

                    try
                    {
                        tx.Commit();
                        TempData["IsValid"] = true;                        

                        return View(model);
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Contact Entry"));

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
        public ActionResult Delete(int id, int propertyInfoId, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Contact Entry"))
            {
                var parent = Repository.GetReference<DetectorInspector.Model.PropertyInfo>(propertyInfoId);
                var model = Repository.Get<ContactEntry>(id);

                parent.RemoveContactEntry(model);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        parent.ApplyUpdatedContactDetails();
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Contact Entry deleted.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Contact Entry"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Contact Entry not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Tenant"));
                    }
                }
            }

            return RedirectToAction("Index", new { id = propertyInfoId });
        }

        [Authorize]
        [ChildActionOnly]
        [Transactional]
        public ActionResult Details(int id)
        {
            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, false, _agencyRepository);

            return PartialView(model);
        }

    }
}