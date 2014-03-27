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
    public class ServiceItemController : SiteController
    {        
        public ServiceItemController(            
            ITransactionFactory transactionFactory,
            IRepository repository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {            
            
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

            var items = Repository.GetAll<ServiceItem>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        code = HttpUtility.HtmlEncode(item.Code),
                        price = StringFormatter.Currency(item.Price),
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
            var model = id == 0 ? new ServiceItemViewModel(Repository) : new ServiceItemViewModel(Repository, Repository.Get<ServiceItem>(id));

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
                var model = isCreated ? new ServiceItem() : Repository.Get<ServiceItem>(id);
                var viewModel = new ServiceItemViewModel(Repository, model);

                if (TryUpdateModel(viewModel, "", null, new string[] { "Id" }))
                {
                    if (Repository.IsNameInUse<Suburb>(model.Name, id))
                    {
                        ShowValidationErrorMessage("Name",
                            string.Format(SR.Unique_Property_Violation_Message, "Name"));

                        return View(viewModel);
                    }

                    Repository.Save(viewModel.ServiceItem);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Service Item saved.");

                        return new ApplySaveResult("Edit", new { id = model.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "ServiceItem"));

                        return View(viewModel);
                    }
                }
                else
                {
                    return View(viewModel);
                }
            }
        }

    }
}
