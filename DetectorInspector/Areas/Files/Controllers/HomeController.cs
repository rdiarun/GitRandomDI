using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using DetectorInspector.Controllers;
using Kiandra.Web.Mvc;
using System.ComponentModel;
using Kiandra.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.Areas.Files.ViewModels;

namespace DetectorInspector.Areas.Files.Controllers
{
    [RequirePermission(Permission.AdministerSystem)]
    public class HomeController : SiteController
    {        
        private IUploadRepository _uploadRepository;

        public HomeController(
            ITransactionFactory transactionFactory,
            IUploadRepository uploadRepository,
            IRepository repository,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
		{			
            _uploadRepository = uploadRepository;
		}

		[HttpGet]
        [Transactional]
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

            var items = Repository.GetAll<UploadContainer>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        name = HttpUtility.HtmlEncode(item.Name)
					}).ToArray()
            };

            return Json(result);
        }

		[HttpGet]
		[Transactional]
		public ActionResult Download(int id)
		{
			var model = _uploadRepository.GetUpload(id);

			return File(model.File, "binary/octet-stream", model.OriginalFileName);
		}


		[HttpGet]
		[Transactional]
		public ActionResult Edit(int? id)
		{
            var viewModel = new UploadContainerViewModel(GetModel<UploadContainer>(id));

			return View(viewModel);
		}

		[HttpPost]
		[ValidateAntiForgeryToken]		
		public ActionResult Edit(int? id, FormCollection form)
		{
            string[] excludeProperties = null;

            var viewModel = new UploadContainerViewModel(GetModel<UploadContainer>(id));
                        
            var action = id.HasValue && id > 0 ? "Edit" : "Create";
            

            using (var tx = TransactionFactory.BeginTransaction(action + " Help"))
            {
                if (id.HasValue && id > 0)
                {
                    //cant upload files in edit mode
                    excludeProperties = new string[] {"Upload"};
                }

                if (TryUpdateModel(viewModel, "", null, excludeProperties, form.ToValueProvider()))
                {
                    Repository.Save(viewModel.UploadContainer);
                            
                    tx.Commit();
                }
            }

            return View(viewModel);
		}

		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Delete(int id, FormCollection form)
		{
			using (var tx = TransactionFactory.BeginTransaction("Delete Upload Container"))
			{
                var model = Repository.Get<UploadContainer>(id);

				if (TryUpdateModel(model, "", new[] { "RowVersion" }, new[] { "Id" }, form.ToValueProvider()))
				{
					try
					{
						model.IsDeleted = true;

						tx.Commit();

						ShowInfoMessage("Success", "Upload Container deleted.");
					}
					catch (DataCurrencyException)
					{
						ShowErrorMessage("Delete Failed",
							string.Format(SR.DataCurrencyException_Delete_Message, "Upload Container"));
					}
				}
			}

			return RedirectToAction("Index");
		}
    }
}
