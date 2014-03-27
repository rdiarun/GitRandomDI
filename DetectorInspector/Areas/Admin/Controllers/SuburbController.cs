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
using DetectorInspector.Areas.Admin.ViewModels;
using DetectorInspector.Controllers;

namespace DetectorInspector.Areas.Admin.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AdministerSystem)]
    public class SuburbController : SiteController
    {        
        private ISuburbRepository _SuburbRepository;
        
        public SuburbController(            
            ITransactionFactory transactionFactory,
            ISuburbRepository SuburbRepository,
            IRepository repository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {            
            _SuburbRepository = SuburbRepository;
        }

        [HttpGet]     
        public ActionResult Index()
        {
            return View();
        }


        [HttpPost]
        [Transactional]
        public ActionResult GetItems(string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            int itemCount;
            int pageCount;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = Repository.GetAll<Suburb>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        postCode = HttpUtility.HtmlEncode(item.PostCode),
                        state = HttpUtility.HtmlEncode(item.State==null ? string.Empty : item.State.Name),
                        zone = HttpUtility.HtmlEncode(item.Zone == null ? string.Empty : item.Zone.Name),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted),
                        createdUtcDate = StringFormatter.UtcToLocalDateTime(item.CreatedUtcDate),
                        createdByUser = HttpUtility.HtmlEncode(item.CreatedByUserName),
                        modifiedUtcDate = StringFormatter.UtcToLocalDateTime(item.ModifiedUtcDate),
                        modifiedByUser = HttpUtility.HtmlEncode(item.ModifiedByUserName)
                    }).ToArray()
            };

            return Json(result);
        }

       
        [HttpGet]        
        [Transactional]
        public ActionResult Edit(int id)
        {
            var model = id == 0 ? new SuburbViewModel(Repository) : new SuburbViewModel(Repository, Repository.Get<Suburb>(id));

            return View(model);
        }

        [HttpPost]       
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, FormCollection collection)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Suburb"))
            {
                var model = isCreated ? new Suburb() : Repository.Get<Suburb>(id);
                var viewModel = new SuburbViewModel(Repository, model);

                if (TryUpdateModel(viewModel, "", null, new string[] { "Id" }))
                {
                    if (Repository.IsNameInUse<Suburb>(model.Name, id))
                    {
                        ShowValidationErrorMessage("Name",
                            string.Format(SR.Unique_Property_Violation_Message, "Name"));

                        return View(viewModel);
                    }

                    Repository.Save(viewModel.Suburb);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Suburb saved.");

                        return new ApplySaveResult("Edit", new { id = model.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Suburb"));

                        return View(viewModel);
                    }
                }
                else
                {
                    return View(viewModel);
                }
            }
        }
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Suburb"))
            {
                var model = Repository.Get<Suburb>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }))
                {
                    try
                    {
                        Repository.Delete(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Suburb deleted.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Suburb"));

                        UpdateModel(model, "", null, new string[] { "Id" });

                        return View("Edit", model);
                    }
                }
            }

            return RedirectToAction("Index");
        }


        [HttpPost]
        [Transactional]
        public ActionResult GetSuburbs(string q, int limit, int? state, string timestamp)
        {
            var items = _SuburbRepository.Search(q, limit, state);

            var result = new
            {
                items = (
                    from item in items
                    select new
                    {
                        id = item.Id.ToString(),
                        name = HttpUtility.HtmlEncode(item.Name),
                        postcode = HttpUtility.HtmlEncode(item.PostCode)
                    }).ToArray()
            };

            return Json(result.items);
        }
    }
}
