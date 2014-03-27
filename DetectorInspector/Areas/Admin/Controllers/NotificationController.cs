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

namespace DetectorInspector.Areas.Admin.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AdministerSystem)]
    public class NotificationController : SiteController
    {                
        public NotificationController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {}

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

            var items = Repository.GetAll<Notification>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        name = HttpUtility.HtmlEncode(item.Name),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
                    }).ToArray()
            };

            return Json(result);
        }

        [HttpGet]
		[Transactional]
        public ActionResult Edit(int id)
        {
            var model = Repository.Get<Notification>(id);

            return View(model);
        }

        [HttpPost]
		[Transactional("Edit Notification")]
        [ValidateAntiForgeryToken]
		[ValidateInput(false)]
        public ActionResult Edit(int id, FormCollection collection)
        {
            var model = Repository.Get<Notification>(id);

			if (TryUpdateModel(model, "", null, new string[] { "Id" }))
			{
                if (Repository.IsNameInUse<Notification>(model.Name, id))
				{
					ShowValidationErrorMessage("Name",
						string.Format(SR.Unique_Property_Violation_Message, "Name"));

					return View(model);
				}

                Repository.Save(model);

				try
				{
					TransactionResult = TransactionResult.Commit;

					ShowInfoMessage("Success", "Notification saved.");

					return new ApplySaveResult("Edit", new { id = model.Id }, "Index");
				}
				catch (DataCurrencyException)
				{
					ShowErrorMessage("Save Failed",
						string.Format(SR.DataCurrencyException_Edit_Message, "Notification"));

					return View(model);
				}
			}
			else
			{
				return View(model);
			}
        }
    }
}
