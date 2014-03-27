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
using DetectorInspector.Areas.Technician.ViewModels;

namespace DetectorInspector.Areas.Technician.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AccessTechnicianDashboard)]
    public class TechnicianAvailabilityController : SiteController
    {
        ITechnicianRepository _technicianRepository;

        public TechnicianAvailabilityController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            ITechnicianRepository technicianRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _technicianRepository = technicianRepository;    
        }

        [HttpGet]
        public ActionResult Index(int id)
        {

            var model = new TechnicianDefaultAvailabilityViewModel(Repository, _technicianRepository, id);

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Index(int id, FormCollection form)
        {


            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Technician"))
            {
                var model = new TechnicianDefaultAvailabilityViewModel(Repository, _technicianRepository, id);


                if (TryUpdateModel(model, "", null, new[] { "Technician.Id" }, form.ToValueProvider()))
                {
                    model.UpdateModel();
                    Repository.Save(model.Technician);
                    try
                    {

                        //save changes (repository.save only needed when creating new)
                        tx.Commit();


                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Technician"));
                    }
                    ShowInfoMessage("Success", "Technician saved.");

                    return new ApplySaveResult("Index", new { id = model.Technician.Id }, "Index");
                }
                else
                {
                    return View(model);
                }

            }
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetItems(int technicianId, string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            var model = _technicianRepository.Get(technicianId);

            int itemCount;
            int pageCount;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = model.CurrentAvailability.GetPage(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        startDate = StringFormatter.LocalDate(item.StartDate),
                        startTime = StringFormatter.LocalTime(item.StartTime),
                        endDate = StringFormatter.LocalDate(item.EndDate),
                        endTime = StringFormatter.LocalTime(item.EndTime),
                        isInclusion = StringFormatter.BooleanToYesNo(item.IsInclusion),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
                    }).ToArray()
            };

            return Json(result);
        }

        [HttpGet]        
        [Transactional]
        public ActionResult Edit(int technicianId, int id)
        {
            var model = new TechnicianAvailabilityViewModel(Repository, _technicianRepository.Get(technicianId), id);

            return View(model);
        }

        [HttpPost]        
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int technicianId, int id, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Availability"))
            {
                var parent = _technicianRepository.Get(technicianId);
                var model = new TechnicianAvailabilityViewModel(Repository, parent, id);

                if (TryUpdateModel(model, "", null, new [] { "TechnicianAvailability.Id" }, form.ToValueProvider()))
				{
                    model.UpdateModel();
                    parent.AddAvailability(model.TechnicianAvailability);
                    Repository.Save(model.TechnicianAvailability);

                    try
                    {
                        tx.Commit();
                        TempData["IsValid"] = true;                        

                        return View(model);
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Availability"));

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
        public ActionResult Delete(int id, int technicianId, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Availability"))
            {
                var parent = Repository.GetReference<DetectorInspector.Model.Technician>(technicianId);
                var model = Repository.Get<TechnicianAvailability>(id);

                parent.RemoveAvailability(model);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Availability deleted.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Availability"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Availability not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Availability"));
                    }
                }
            }

            return RedirectToAction("Index", "TechnicianAvailability", new { id = technicianId });
        }


        [HttpGet]
        [Transactional]
        public ActionResult AvailableTechnician(string date)
        {
            var model = new AvailableTechnicianViewModel(Repository, DateTime.Parse(date));

            return PartialView(model);
        }


        [HttpPost]
        [Transactional]
        public ActionResult AvailableTechnicianList(string date)
        {
            var bookingDate = DateTime.Parse(date);
            var model = new AvailableTechnicianViewModel(Repository, bookingDate);


            return Json(from t in model.Technicians
                        select new { id = t.Id, name = t.Name, conditions = t.GetConditions(bookingDate) });
        }

        public ActionResult Availability(int id)
        {
            var model = _technicianRepository.Get(id);
            return View(model);
        }
    }
}