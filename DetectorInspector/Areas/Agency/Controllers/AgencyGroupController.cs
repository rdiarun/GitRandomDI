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

using System.Collections.Generic;
namespace DetectorInspector.Areas.Agency.Controllers
{
    [HandleError]
    // [RequirePermission(Permission.AdministerSystem)]
    public class AgencyGroupController : SiteController
    {
        private readonly IAgencyRepository _agencyRepository;
        public AgencyGroupController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository,
            IAgencyRepository AgencyRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _agencyRepository = AgencyRepository;
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

            var items = Repository.GetActive<AgencyGroup>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
            var model = new AgencyGroupViewModel(Repository, id);

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Agency Group"))
            {
                var model = new AgencyGroupViewModel(Repository, id);

                if (TryUpdateModel(model, "", null, new[] { "AgencyGroup.Id" }, form.ToValueProvider()))
                {
                    if (Repository.IsNameInUse<AgencyGroup>(model.AgencyGroup.Name, id))
                    {
                        ShowValidationErrorMessage("Name",
                            string.Format(SR.Unique_Property_Violation_Message, "Name"));

                        return View(model);
                    }

                    Repository.Save(model.AgencyGroup);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Agency Group saved.");

                        return new ApplySaveResult("Edit", new { id = model.AgencyGroup.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Agency Group"));

                        return View(model);
                    }
                }
                else
                {
                    return View(model);
                }
            }
        }

        //[HttpPost]
        //[ValidateAntiForgeryToken]
        //public ActionResult Delete(int id, FormCollection form)
        //{
        //    using (var tx = TransactionFactory.BeginTransaction("Delete Agency Group"))
        //    {
        //        var model = Repository.Get<AgencyGroup>(id);

        //        if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
        //        {
        //            try
        //            {
        //                //  var IsAgenctIdExist;
        //                // IsAgenctIdExist = Repository.GetAgencyIdByAgencyGroupIdID(id);
        //                //  GetAgencyIdByAgencyGroupIdID(model, id);
        //                //   Repository.GetAgencyIdByAgencyGroupIdID

        //                var IsAgenctIdExist = _agencyRepository.GetAgencyIdByAgencyGroupIdID(id);
        //                if (IsAgenctIdExist.Count() == 0)
        //                {

        //                    model.IsDeleted = true;
        //                    Repository.Save(model);

        //                    tx.Commit();

        //                    ShowInfoMessage("Success", "Agency Group deleted.");
        //                }
        //                else
        //                {
        //                    ShowErrorMessage("Error", "Agency Group is currently in use and has not been deleted.");
        //                }
        //            }
        //            catch (DataCurrencyException)
        //            {
        //                ShowErrorMessage("Delete Failed",
        //                    string.Format(SR.DataCurrencyException_Delete_Message, "Agency Group"));
        //            }
        //            catch (EntityInUseException)
        //            {
        //                ShowInfoMessage("Agency Group not deleted",
        //                    string.Format(SR.EntityInUseException_Delete_Message, "Agency Group"));
        //            }
        //        }
        //    }

        //    return RedirectToAction("Index");
        //}



        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Agency Group"))
            {
                var model = Repository.Get<AgencyGroup>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        //  var IsAgenctIdExist;
                        // IsAgenctIdExist = Repository.GetAgencyIdByAgencyGroupIdID(id);
                        //  GetAgencyIdByAgencyGroupIdID(model, id);
                        //   Repository.GetAgencyIdByAgencyGroupIdID

                        var IsAgenctIdExist = _agencyRepository.GetAgencyIdByAgencyGroupIdID(id);
                        if (IsAgenctIdExist.Count() == 0)
                        {

                            model.IsDeleted = true;
                            Repository.Save(model);

                            tx.Commit();

                            ShowInfoMessage("Success", "Agency Group deleted.");
                        }
                        else
                        {
                            ShowErrorMessage("Error", "Agency Group is currently in use and has not been deleted.");
                        }
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Agency Group"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Agency Group not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Agency Group"));
                    }
                }
            }

            return RedirectToAction("Index");
        }



        //[HttpPost]
        //[ValidateAntiForgeryToken]
        //public ActionResult Delete(int id, FormCollection form)
        //{
        //       using (var tx = TransactionFactory.BeginTransaction("Delete Agency Group"))
        //    {
        //        var model = Repository.Get<AgencyGroup>(id);

        //        if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
        //        {
        //            try
        //            {
        //                  var IsAgenctIdExist;
        //                 IsAgenctIdExist = Repository.GetAgencyIdByAgencyGroupIdID(id);
        //                  GetAgencyIdByAgencyGroupIdID(model, id);
        //                   Repository.GetAgencyIdByAgencyGroupIdID

        //                int IsAgenctIdExist = _agencyRepository.GetAgencyGroup(id);
        //                if (IsAgenctIdExist == 10)
        //                {

        //                    model.IsDeleted = true;
        //                    Repository.Save(model);

        //                       tx.Commit();

        //                    ShowInfoMessage("Success", "Agency Group deleted.");
        //                }
        //                else if (IsAgenctIdExist == 0)
        //                {
        //                    ShowErrorMessage("Error", "Agency Group is currently in use and has not been deleted.");
        //                }
        //            }
        //            catch (DataCurrencyException)
        //            {
        //                ShowErrorMessage("Delete Failed",
        //                    string.Format(SR.DataCurrencyException_Delete_Message, "Agency Group"));
        //            }
        //            catch (EntityInUseException)
        //            {
        //                ShowInfoMessage("Agency Group not deleted",
        //                    string.Format(SR.EntityInUseException_Delete_Message, "Agency Group"));
        //            }
        //        }
        //    }

        //    return RedirectToAction("Index");
        //}



        //public IEnumerable<AgencyGroup> GetAgencyIdByAgencyGroupIdIDa(int Id)
        //{
        //    var Agency = new  List<Agency>();
        //    var AgencyGroupIdId = from b in Agency
        //                          where b.IsDeleted.Equals(false)
        //                           & b.AgencyGroup.Id.Equals(Id)
        //                          select b.AgencyGroup.Id;
        //   // return AgencyGroupIdId.First();
        //    return Agency;
        //}

    }
}