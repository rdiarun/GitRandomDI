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
using Kiandra.Entities;

namespace DetectorInspector.Areas.Admin.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AdministerSystem)]
    public class HelpController : SiteController
    {             
		private IHelpRepository _helpRepository;

        public HelpController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {                      
			_helpRepository = helpRepository;
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

            var items = _helpRepository.GetAll(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        title = HttpUtility.HtmlEncode(item.Title),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
                    }).ToArray()
            };

            return Json(result);
        }

        [HttpGet]        
        [Transactional]
        public ActionResult Edit(Guid? id)
        {
            var model = GetModel<Help>(id);

            return View(model);
        }
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int? id, FormCollection collection)
        {
            var action = id.Equals(Guid.Empty) ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Help"))
            {
                var model = GetModel<Help>(id);

                if (TryUpdateModel(model, "", null, new string[] { "Id" }))
                {
                    if (_helpRepository.IsTitleInUse(model.Title, id))
                    {
                        ShowValidationErrorMessage("Title",
                            string.Format(SR.Unique_Property_Violation_Message, "Title"));

                        return View(model);
                    }

                    Repository.Save(model);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Help saved.");

                        return new ApplySaveResult("Edit", new { id = model.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Help"));

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
        public ActionResult EditPage(string code)
        {            
            var viewModel = new PageHelpViewModel(HelpRepository.GetHelp(code) ?? new Help(), code);

            return View(viewModel);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult EditPage(string code, FormCollection collection)
        {
            var viewModel = new PageHelpViewModel(HelpRepository.GetHelp(code) ?? new Help(), code);

            var action = viewModel.Help.Id > 0 ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Help"))
            {
                if (TryUpdateModel(viewModel.Help, "Help", null, new string[] { "Id" }))
                {
                    if (_helpRepository.IsTitleInUse(viewModel.Help.Title, viewModel.Help.Id))
                    {
                        ShowValidationErrorMessage("Title",
                            string.Format(SR.Unique_Property_Violation_Message, "Title"));
                    }
                    else
                    {
                        Repository.Save(viewModel.Help);


                        try
                        {
                            tx.Commit();

                            ShowInfoMessage("Success", "Help saved.");

                            return View("CloseDialog");
                        }
                        catch (DataCurrencyException)
                        {
                            ShowErrorMessage("Save Failed",
                                string.Format(SR.DataCurrencyException_Edit_Message, "Help"));

                        }
                    }
                }

                return View(viewModel);               
            }
        }

     
        [Transactional]
        [HttpGet]
        public ActionResult ShowHelp(int id)
        {
            var model = Repository.Get<Help>(id);

            if (model == null)
            {
                return View("HelpNotFound");
            }
            
            return View(model);
            
        }
    }
}