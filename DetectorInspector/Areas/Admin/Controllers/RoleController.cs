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
using DetectorInspector.Areas.Admin.ViewModels;

namespace DetectorInspector.Areas.Admin.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AdministerSystem)]
    public class RoleController : SiteController
    {           
        private IRoleRepository _roleRepository;

        public RoleController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IRoleRepository roleRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {            
            _roleRepository = roleRepository;
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

            var items = Repository.GetAll<Role>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
                    }).ToArray()
            };

            return Json(result);
        }

        [HttpGet]        
        [Transactional]
        public ActionResult Edit(int id)
        {
			var model = id == 0 ? new RoleViewModel(_roleRepository) : new RoleViewModel(_roleRepository, id);

            return View(model);
        }

        [HttpPost]        
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Role"))
            {
				var model = id == 0 ? new RoleViewModel(_roleRepository) : new RoleViewModel(_roleRepository, id);

                if (TryUpdateModel(model, "", null, new [] { "Role.Id" }, form.ToValueProvider()))
				{
                    if (Repository.IsNameInUse<Role>(model.Role.Name, id))
                    {
                        ShowValidationErrorMessage("Name",
                            string.Format(SR.Unique_Property_Violation_Message, "Name"));

                        return View(model);
                    }

                    Repository.Save(model.Role);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Role saved.");

                        return new ApplySaveResult("Edit", new { id = model.Role.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Role"));

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
            using (var tx = TransactionFactory.BeginTransaction("Delete Role"))
            {
                var model = Repository.Get<Role>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        Repository.Delete(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Role deleted.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Role"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Role not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Role"));
                    }
                }
            }

            return RedirectToAction("Index");
        }

    }
}