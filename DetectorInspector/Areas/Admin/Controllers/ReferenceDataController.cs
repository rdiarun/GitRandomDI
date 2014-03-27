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
using DetectorInspector.Controllers;

namespace DetectorInspector.Areas.Admin.Controllers
{
    [RequirePermission(Permission.AdministerSystem)]
	public class ReferenceDataController : SiteController
	{
        public ReferenceDataController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        { }

		public ActionResult Index()
		{
			return View();
		}
	}

    [HandleError]
    [RequirePermission(Permission.AdministerSystem)]
	public class ReferenceDataController<T> : SiteController
		where T : class, ILookupEntity, new()
	{				
		private string _entityTypeDisplayName;
        private string _entityTypeName;

		public ReferenceDataController(
            ITransactionFactory transactionFactory, 
            IRepository repository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
		{			
            _entityTypeName = typeof(T).Name;
            _entityTypeDisplayName = modelMetadataProvider.GetModelDisplayName(typeof(T));
		}

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            ViewData["EntityTypeDisplayName"] = _entityTypeDisplayName;
            ViewData["EntityTypeName"] = _entityTypeName;
            base.OnActionExecuting(filterContext);
        }

		[HttpGet]
		public ActionResult List()
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

            var items = Repository.GetAll<T>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
            var model = id == 0 ? new T() : Repository.Get<T>(id);
            return View(model);
		}

		[HttpPost]		
		[ValidateAntiForgeryToken]
        public ActionResult Edit(int id, FormCollection collection)
		{
			var action = id == 0 ? "Create" : "Edit";

			using (var tx = TransactionFactory.BeginTransaction(action + " " + _entityTypeDisplayName))
			{
                var model = id == 0 ? new T() : Repository.Get<T>(id);

				if (TryUpdateModel(model, "", null, new[] { "Id"}))
				{
					if (Repository.IsNameInUse<T>(model.Name, id))
					{
						ShowValidationErrorMessage("Name",
							string.Format(SR.Unique_Property_Violation_Message, "Name"));

						return View(model);
					}

                    Repository.Save(model);

					try
					{
						tx.Commit();

						ShowInfoMessage("Success", _entityTypeDisplayName + " saved.");

						return new ApplySaveResult("Edit", new { id = model.Id }, "List");
					}
					catch (DataCurrencyException)
					{
						ShowErrorMessage("Save Failed",
							string.Format(SR.DataCurrencyException_Edit_Message, _entityTypeDisplayName));

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
			using (var tx = TransactionFactory.BeginTransaction("Delete " + _entityTypeDisplayName))
			{
                var model = Repository.Get<T>(id);

				if (TryUpdateModel(model, "", new[] { "RowVersion" }, new[] { "Id" }, form.ToValueProvider()))
				{
					try
					{
                        Repository.Delete(model);

						tx.Commit();

						ShowInfoMessage("Success", _entityTypeDisplayName + " deleted.");
					}
					catch (DataCurrencyException)
					{
						ShowErrorMessage("Delete Failed",
							string.Format(SR.DataCurrencyException_Delete_Message, _entityTypeDisplayName));
					}
					catch (EntityInUseException)
					{
						ShowInfoMessage(_entityTypeDisplayName + " not deleted", 
							string.Format(SR.EntityInUseException_Delete_Message, _entityTypeDisplayName));
					}
				}
			}

			return RedirectToAction("List");
		}
	}
}
