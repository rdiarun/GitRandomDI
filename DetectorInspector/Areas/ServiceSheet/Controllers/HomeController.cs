using System;
using System.ComponentModel;
using System.Data.SqlTypes;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DetectorInspector.Areas.ServiceSheet.ViewModels;
using DetectorInspector.Controllers;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using Kiandra.Data;
using Kiandra.Web.Mvc;

namespace DetectorInspector.Areas.ServiceSheet.Controllers
{
    [HandleError]
   // [RequirePermission(Permission.AdministerSystem)]
    public class HomeController : SiteController
    {
        private readonly IBookingRepository _bookingRepository;
        private readonly IPropertyRepository _propertyRepository;

        public HomeController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IBookingRepository bookingRepository,
            IPropertyRepository propertyRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _bookingRepository = bookingRepository;
            _propertyRepository = propertyRepository;
        }

        [HttpGet]
        public ActionResult Index()
        {
            var model = new ServiceSheetSearchViewModel(Repository, true, true);
            return View(model);
        }


        [HttpGet]
        public ActionResult Edit(int id, int? propertyInfoId)
        {
            using (var tx = TransactionFactory.BeginTransaction("Get Service Sheet"))
            {
                var model = _bookingRepository.GetServiceSheet(id, true);

                if (propertyInfoId.HasValue)
                {
                    var propertyInfo = _propertyRepository.Get(propertyInfoId.Value);
                    //model.AssignProperty(propertyInfo);
                }

                if (model.Id == 0)
                {
                    Repository.Save<Model.ServiceSheet>(model);
                    tx.Commit();
                }
                var viewModel = new ServiceSheetViewModel(Repository, model.Booking, model.Id);
                return View(viewModel);
            }
        }

        [HttpPost]
        public ActionResult EditServiceSheetItem(
            int serviceSheetId,
            int id,
            string location,
            int? detectorTypeId,
            string manufacturer,
            int? expiryYear,
            int? newExpiryYear,
            bool isBatteryReplaced,
            bool isReplacedByElectrician,
            bool isRepositioned,
            bool isCleaned, 
            bool hasSticker, 
            bool isDecibelTested,
            bool isOptional,
            bool hasProblem
             )
        {

            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Service Sheet Item"))
            {
                var parent = Repository.Get<DetectorInspector.Model.ServiceSheet>(serviceSheetId);
                var detector = new Detector(parent.Booking.PropertyInfo);
                var model = id!=0?Repository.Get<ServiceSheetItem>(id):new ServiceSheetItem(parent, detector);
                if (detectorTypeId.HasValue)
                {
                    model.DetectorType = Repository.GetReference<DetectorType>(detectorTypeId.Value);
                }
                model.Location = location;
                model.Manufacturer = manufacturer;
                model.IsDecibelTested = isDecibelTested;
                if (expiryYear.HasValue)
                {
                    model.ExpiryYear = expiryYear.Value;
                }
                else
                {
                    model.ExpiryYear = null;
                }
                if (newExpiryYear.HasValue)
                {
                    model.NewExpiryYear = newExpiryYear.Value;
                }
                else
                {
                    model.NewExpiryYear = null;
                }
                model.HasSticker = hasSticker;
                model.IsBatteryReplaced = isBatteryReplaced;
                model.IsCleaned = isCleaned;
                model.IsReplacedByElectrician = (newExpiryYear.HasValue) || isReplacedByElectrician;
                model.IsRepositioned = isRepositioned;
                model.IsOptional = isOptional;
                model.HasProblem = hasProblem;
                parent.AddServiceSheetItem(model);
                Repository.Save(model);

                try
                {
                    tx.Commit();

                    return Json(new { success = true });
                }
                catch (DataCurrencyException)
                {
                    ShowErrorMessage("Save Failed",
                        string.Format(SR.DataCurrencyException_Edit_Message, "Service Item"));

                    return Json(new { success = false });
                }
            }
        }
        [HttpGet]
        public ActionResult ElectricalJob(int id, int? propertyInfoId)
        {
            using (var tx = TransactionFactory.BeginTransaction("Get Electrical Job"))
            {
                if (propertyInfoId.HasValue)
                {
                    var propertyInfo = _propertyRepository.Get(propertyInfoId.Value);


                    var model = id != 0 ? _bookingRepository.GetElectricalJob(id) : new Model.Booking(propertyInfo);

                    if (id == 0)
                    {
                        model.IsDeleted = true;
                        Repository.Save<Model.Booking>(model);
                        var serviceSheet = new Model.ServiceSheet(model, true);
                        serviceSheet.IsDeleted = true;
                        serviceSheet.Discount = 0; // Remove the discount link to property discount
                        Repository.Save<Model.ServiceSheet>(serviceSheet);
                        tx.Commit();
                        return RedirectToAction("ElectricalJob", new { id=model.Id, propertyInfoId = propertyInfo.Id});
                    }
                    var viewModel = new ElectricalJobViewModel(Repository, _bookingRepository, model.Id);
                    return View(viewModel);
                }
                else
                {
                    return View(new ElectricalJobViewModel(Repository, _bookingRepository, id));
                }
            }
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ElectricalJob(int id, int propertyInfoId, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";
            var model = _bookingRepository.GetElectricalJob(id);

            using (var tx = TransactionFactory.BeginTransaction(action + " Electrical Job"))
            {
                var viewModel = new ElectricalJobViewModel(Repository, _bookingRepository, model.Id);

                if (TryUpdateModel(viewModel, "", null, null, form.ToValueProvider()))
                {
                    viewModel.ServiceSheet.Consolidate();
                    Repository.Save(viewModel.ServiceSheet);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Electrical Job saved.");

                        TempData["RefreshGrid"] = "true";

                        if (JsWindowHelper.IsWindowToClose(this.ControllerContext))
                        {
                            TempData["CloseDialog"] = "true";
                        }
                        else
                        {
                            TempData["CloseDialog"] = "false";
                        }

                        return new ApplySaveResult("ElectricalJob", new { id = model.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Electrical Job"));

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
        public ActionResult Edit(int id, int bookingId, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";
            var model = _bookingRepository.GetServiceSheet(bookingId);

            using (var tx = TransactionFactory.BeginTransaction(action + " Service Sheet"))
            {
                var viewModel = new ServiceSheetViewModel(Repository, model.Booking, model.Id);

                if (TryUpdateModel(viewModel, "", null, null, form.ToValueProvider()))
                {
                    if (model.HasProblem && model.ProblemNotes == null)
                    {
                        ShowErrorMessage("Error", "Problem Notes are required.");
                        return View(viewModel);
                    }

                    if (model.IsElectricianRequired && model.ElectricalNotes == null)
                    {
                        ShowErrorMessage("Error", "Electrical Notes are required.");
                        return View(viewModel);
                    }
                    model.Consolidate();
                    Repository.Save(model);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Service Sheet saved.");
                        
                        TempData["DialogValue"] = "property-service-sheet";

                        if (JsWindowHelper.IsWindowToClose(this.ControllerContext))
                        {
                            TempData["CloseDialog"] = "true";
                        }
                        else
                        {
                            TempData["CloseDialog"] = "false";
                        }

                        return new ApplySaveResult("Edit", new { id = model.Booking.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Service Sheet"));

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
        [Transactional]
        public ActionResult GetServiceSheetItems(int? propertyInfoId, int bookingId, string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            int itemCount;
            int pageCount;

            var serviceSheet = _bookingRepository.GetServiceSheet(bookingId);
            if (propertyInfoId.HasValue)
            {
                var propertyInfo = _propertyRepository.Get(propertyInfoId.Value);
                serviceSheet.AssignProperty(propertyInfo);
            }            

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = serviceSheet.ActiveItems.GetPage(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        expiryYear = item.ExpiryYear.ToString(),
                        detectorType = HttpUtility.HtmlEncode(item.DetectorType.Name),
                        location = HttpUtility.HtmlEncode(item.Location),
                        manufacturer = HttpUtility.HtmlEncode(item.Manufacturer),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted),
                        isOptional = StringFormatter.BooleanToYesNo(item.IsOptional)
                    }).ToArray()
            };

            return Json(result);
        }




        [HttpPost]
        [Transactional]
        public ActionResult GetServiceSheetsForDate(string bookingDate, string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            int itemCount;
            int pageCount;

            // int pageNumber = 1;
            
            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            //Added filtering by Technician Id to remove un-allocated bookings.
            var items = _bookingRepository.GetServiceSheetsForDateRange(
                SqlDateTime.MinValue.Value,
                DateTime.Parse(bookingDate),
                sortBy,
                listSortDirection,
                pageNumber, pageSize,
                out itemCount, out pageCount);

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
                        propertyInfoId = item.PropertyInfoId.ToString(),
                        propertyNumber = item.PropertyNumber.ToString(),
                        unitShopNumber = HttpUtility.HtmlEncode(item.UnitShopNumber ?? string.Empty),
                        streetNumber = HttpUtility.HtmlEncode(item.StreetNumber),
                        streetName = HttpUtility.HtmlEncode(item.StreetName),
                        state = HttpUtility.HtmlEncode(item.State),
                        suburb = HttpUtility.HtmlEncode(item.Suburb),
                        postCode = HttpUtility.HtmlEncode(item.PostCode),
                        agencyName = HttpUtility.HtmlEncode(item.AgencyName ?? string.Empty),
                        propertyManager = HttpUtility.HtmlEncode(item.PropertyManager ?? string.Empty),
                        keyNumber = HttpUtility.HtmlEncode(item.KeyNumber ?? string.Empty),
                        tenantName = HttpUtility.HtmlEncode(item.TenantName ?? string.Empty),
                        tenantContactNumber = HttpUtility.HtmlEncode(item.TenantContactNumber ?? string.Empty),
                        lastServicedDate = StringFormatter.LocalDate(item.LastServicedDate),
                        nextServiceDate = StringFormatter.LocalDate(item.NextServiceDate),
                        technicianId = item.TechnicianId.ToString(),
                        technicianName = HttpUtility.HtmlEncode(item.TechnicianName ?? "Unallocated"),
                        bookingDate = item.BookingDate == null ? string.Empty : StringFormatter.LocalDate(item.BookingDate),
                        bookingTime = item.BookingTime == null ? string.Empty : StringFormatter.LocalTime(item.BookingTime),
                        duration = item.Duration.ToString(),
                        notes = item.Notes,
                        hasServiceSheet = item.HasServiceSheet,
                        contactNotes = item.ContactNotes,
                        keyTime = HttpUtility.HtmlEncode(item.KeyTime),
                        rowVersion = Convert.ToBase64String(item.RowVersion)
                    }).ToArray()
            };
            return Json(result);
        }


        [HttpGet]
        [Transactional]
        public ActionResult EditServiceSheetItem(int bookingId, bool isClone)
        {
            var serviceSheet = _bookingRepository.GetServiceSheet(bookingId);
            var detector = new Detector(serviceSheet.Booking.PropertyInfo);
            if (isClone)
            {
                var serviceSheetItem = new ServiceSheetItem(serviceSheet, detector);
                if (serviceSheet.ActiveItems.Count() > 0)
                {
                    var clonedItem = serviceSheet.ActiveItems.Last();
                    serviceSheetItem.DetectorType = clonedItem.DetectorType;
                    serviceSheetItem.ExpiryYear = clonedItem.ExpiryYear;
                    serviceSheetItem.HasSticker = clonedItem.HasSticker;
                    serviceSheetItem.IsBatteryReplaced = clonedItem.IsBatteryReplaced;
                    serviceSheetItem.IsCleaned = clonedItem.IsCleaned;
                    serviceSheetItem.IsDecibelTested = clonedItem.IsDecibelTested;
                    serviceSheetItem.IsReplacedByElectrician = clonedItem.IsReplacedByElectrician;
                    serviceSheetItem.IsRepositioned = clonedItem.IsRepositioned;
                    serviceSheetItem.Manufacturer = clonedItem.Manufacturer;
                    serviceSheetItem.NewExpiryYear = clonedItem.NewExpiryYear;
                }
                serviceSheet.AddServiceSheetItem(serviceSheetItem);
            }
            else
            {
                serviceSheet.AddServiceSheetItem(new ServiceSheetItem(serviceSheet, detector));
            }
            var model = new ServiceSheetViewModel(Repository, serviceSheet.Booking, serviceSheet.Id);

            return View(model);
        }

        //[HttpPost]
        //[ValidateAntiForgeryToken]
        //public ActionResult EditServiceSheetItem(int serviceSheetId, int id, FormCollection form)
        //{
        //    bool isCreated = id == 0;
        //    var action = isCreated ? "Create" : "Edit";

        //    using (var tx = TransactionFactory.BeginTransaction(action + " Contact Info"))
        //    {
        //        var parent = Repository.Get<DetectorInspector.Model.ServiceSheet>(serviceSheetId);
        //        var model = new ServiceSheetItemViewModel(Repository, parent, id);

        //        if (TryUpdateModel(model, "", null, new[] { "ServiceSheet.Id" }, form.ToValueProvider()))
        //        {
        //            parent.AddServiceSheetItem(model.ServiceSheetItem);

        //            Repository.Save(model.ServiceSheetItem);

        //            try
        //            {
        //                tx.Commit();
        //                TempData["IsValid"] = true;

        //                return View(model);
        //            }
        //            catch (DataCurrencyException)
        //            {
        //                ShowErrorMessage("Save Failed",
        //                    string.Format(SR.DataCurrencyException_Edit_Message, "Service Item"));

        //                return View(model);
        //            }
        //        }
        //        else
        //        {
        //            return View(model);
        //        }
        //    }
        //}

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteServiceSheetItem(int id, int serviceSheetId, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Service Item"))
            {
                var parent = Repository.GetReference<DetectorInspector.Model.ServiceSheet>(serviceSheetId);
                var model = Repository.Get<ServiceSheetItem>(id);

                parent.RemoveServiceSheetItem(model);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Service Item deleted.");
                        return Json(new { success = true });
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Service Item"));
                        return Json(new { success = false });
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Service Item not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Service Item"));
                        return Json(new { success = false });
                    }
                }
                else
                {
                    return Json(new { success = false });
                }
            }

        }


    }
}