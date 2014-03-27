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
using DetectorInspector.Areas.Agency.ViewModels;

namespace DetectorInspector.Areas.Agency.Controllers
{
    [HandleError]
  //  [RequirePermission(Permission.AdministerSystem)]
    public class PropertyManagerController : SiteController
    {
        IAgencyRepository _agencyRepository;

        public PropertyManagerController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IAgencyRepository agencyRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _agencyRepository = agencyRepository;    
        }

        [HttpGet]
        public ActionResult Index(int id)
        {

            var model = new AgencyViewModel(Repository, _agencyRepository, id);

            return View(model);
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetItems(int agencyId, string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            var model = _agencyRepository.Get(agencyId);

            int itemCount;
            int pageCount;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = model.ActivePropertyManagers.GetPage(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        position = HttpUtility.HtmlEncode(item.Position),
                        telephone = HttpUtility.HtmlEncode(item.Telephone),
                        email = HttpUtility.HtmlEncode(item.Email),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
                    }).ToArray()
            };

            return Json(result);
        }

        [HttpGet]        
        [Transactional]
        public ActionResult Edit(int agencyId, int id)
        {
            var model = new PropertyManagerViewModel(Repository, _agencyRepository.Get(agencyId), id);

            return View(model);
        }

        [HttpPost]        
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int agencyId, int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Property Manager"))
            {
                var parent = _agencyRepository.Get(agencyId);
                var model = new PropertyManagerViewModel(Repository, parent, id);

                if (TryUpdateModel(model, "", null, new [] { "PropertyManager.Id" }, form.ToValueProvider()))
				{
                    parent.AddPropertyManager(model.PropertyManager);
                    if (Repository.IsNameInUse<PropertyManager>(model.PropertyManager.Name, id))
                    {
                        ShowValidationErrorMessage("Name",
                            string.Format(SR.Unique_Property_Violation_Message, "Name"));

                        return View(model);
                    }

                    Repository.Save(model.PropertyManager);

                    try
                    {
                        tx.Commit();

                        TempData["IsValid"] = true;                        

                        return View(model);
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Property Manager"));

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
        public ActionResult Delete(int id, int agencyId, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Property Manager"))
            {
                var parent = Repository.Get<DetectorInspector.Model.Agency>(agencyId);
                var model = Repository.Get<PropertyManager>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        parent.RemovePropertyManager(model);
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

            return RedirectToAction("Index", "PropertyManager", new { id = agencyId });
        }

    }
}