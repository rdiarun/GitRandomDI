using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DetectorInspector.Areas.Booking.ViewModels;
using DetectorInspector.Controllers;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using Kiandra.Data;
using Kiandra.Web.Mvc;

namespace DetectorInspector.Areas.Booking.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AccessBookings)]
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
            var model = new BookingSearchViewModel(Repository, true, true);
            return View(model);
        }

        public ActionResult Schedule()
        {
            var model = new BookingScheduleViewModel(Repository, true, true);
            return View(model);
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetItems(int? propertyInfoId, string sortBy, string sortDirection, int pageNumber, int pageSize)
        {
            int itemCount;
            int pageCount;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            IEnumerable<DetectorInspector.Model.Booking> items;
            if (propertyInfoId.HasValue)
            {

                var propertyInfo = _propertyRepository.Get(propertyInfoId.Value);

                items = propertyInfo.ActiveBookings.GetPage(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);
            }
            else
            {
                items = Repository.GetAll<DetectorInspector.Model.Booking>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);
            }

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
                        propertyInfoId = item.PropertyInfo.Id.ToString(),
                        propertyNumber = item.PropertyInfo.PropertyNumber.ToString(),
                        unitShopNumber = HttpUtility.HtmlEncode(item.PropertyInfo.UnitShopNumber != null ? item.PropertyInfo.UnitShopNumber : string.Empty),
                        streetNumber = HttpUtility.HtmlEncode(item.PropertyInfo.StreetNumber.ToString()),
                        streetName = HttpUtility.HtmlEncode(item.PropertyInfo.StreetName.ToString()),
                        state = HttpUtility.HtmlEncode(item.PropertyInfo.State == null ? string.Empty : item.PropertyInfo.State.ToString()),
                        suburb = HttpUtility.HtmlEncode(item.PropertyInfo.Suburb == null ? string.Empty : item.PropertyInfo.Suburb.ToString()),
                        postCode = HttpUtility.HtmlEncode(item.PropertyInfo.PostCode.ToString()),
                        agencyName = HttpUtility.HtmlEncode(item.PropertyInfo.Agency != null ? item.PropertyInfo.Agency.Name : string.Empty),
                        propertyManager = HttpUtility.HtmlEncode(item.PropertyInfo.PropertyManager != null ? item.PropertyInfo.PropertyManager.Name : string.Empty),
                        keyNumber = HttpUtility.HtmlEncode(item.KeyNumber != null ? item.KeyNumber : string.Empty),
                        lastServicedDate = StringFormatter.LocalDate(item.PropertyInfo.LastServicedDate),

                        technicianId = HttpUtility.HtmlEncode(item.Technician != null ? item.Technician.Id.ToString() : string.Empty),
                        technicianName = HttpUtility.HtmlEncode(item.Technician != null ? item.Technician.Name : string.Empty),

                        bookingDate = StringFormatter.LocalDate(item.Date),
                        bookingTime = StringFormatter.LocalTime(item.Time),
                        duration = item.Duration.ToString(),
                        notes = item.Notes,
                        keyTime = HttpUtility.HtmlEncode(item.Time.HasValue ? string.Format("{0}-{1}", item.Time.Value.ToString("hh:mm tt"), item.Time.Value.AddMinutes(item.Duration).ToString("hh:mm tt")) : item.KeyNumber),
                        hasServiceSheet = item.HasServiceSheet,
                        isElectricianRequired = StringFormatter.BooleanToYesNo(item.IsElectricianRequired),
                        isElectrical = StringFormatter.BooleanToYesNo(item.HasServiceSheet ? item.ServiceSheet.IsElectrical : false),
                        hasProblem = StringFormatter.BooleanToYesNo(item.HasProblem),
                        isCompleted = StringFormatter.BooleanToYesNo(item.IsCompleted),
                        rowVersion = Convert.ToBase64String(item.RowVersion)
                    }).ToArray()
            };

            return Json(result);
        }


        [HttpPost]
        [Transactional]
        public ActionResult GetBookingsForDate(string bookingDate, string sortBy, string sortDirection)
        {
            int itemCount;
            int pageCount;
            int pageNumber = 1;
            int pageSize = 1000;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = _bookingRepository.GetBookingsForDate(
                DateTime.Parse(bookingDate),
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
                        hasProblem = StringFormatter.BooleanToYesNo(item.HasProblem),
                        hasLargeLadder = StringFormatter.BooleanToYesNo(item.HasLargeLadder),
                        lastServicedDate = StringFormatter.LocalDate(item.LastServicedDate),
                        nextServiceDate = StringFormatter.LocalDate(item.NextServiceDate),
                        technicianId = item.TechnicianId.ToString(),
                        technicianName = HttpUtility.HtmlEncode(item.TechnicianName ?? string.Empty),
                        bookingDate = StringFormatter.LocalDate(item.BookingDate),
                        bookingTime = StringFormatter.LocalTime(item.BookingTime),
                        actualBookingTime = item.BookingTime.HasValue ? item.BookingTime.Value.ToLocalTime() : DateTime.MinValue,
                        duration = item.Duration.ToString(),
                        notes = item.Notes,
                        keyTime = HttpUtility.HtmlEncode(item.KeyTime ?? string.Empty),
                        rowVersion = Convert.ToBase64String(item.RowVersion)
                    }).OrderBy(x => x.actualBookingTime).ToArray()
            };
            return Json(result);
        }


        [HttpPost]
        [Transactional]
        public ActionResult GetBookingsForDateRange(string bookingDate, string sortBy, string sortDirection)
        {
            int itemCount;
            int pageCount;
            int pageNumber = 1;
            int pageSize = 1000;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var preferredDate = DateTime.Parse(bookingDate);

            var items = _bookingRepository.GetBookingsForDateRange(
                preferredDate,
                preferredDate.AddDays(14),
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
                        hasProblem = StringFormatter.BooleanToYesNo(item.HasProblem),
                        hasLargeLadder = StringFormatter.BooleanToYesNo(item.HasLargeLadder),
                        lastServicedDate = StringFormatter.LocalDate(item.LastServicedDate),
                        nextServiceDate = StringFormatter.LocalDate(item.NextServiceDate),
                        technicianId = item.TechnicianId.ToString(),
                        technicianName = HttpUtility.HtmlEncode(item.TechnicianName ?? string.Empty),
                        bookingDate = StringFormatter.LocalDate(item.BookingDate),
                        bookingTime = StringFormatter.LocalTime(item.BookingTime),
                        ActualBookingTime = item.BookingTime.HasValue ? item.BookingTime.Value.ToLocalTime() : DateTime.MinValue,
                        duration = item.Duration.ToString(),
                        notes = item.Notes,
                        keyTime = HttpUtility.HtmlEncode(item.KeyTime ?? string.Empty),
                        rowVersion = Convert.ToBase64String(item.RowVersion)
                    }).OrderBy(x => x.ActualBookingTime).ToArray()
            };
            return Json(result);
        }




        [HttpPost]
        [Transactional]
        public ActionResult GetBookingsForSlot(int? technicianId, DateTime? time, string sortBy, string sortDirection, int pageNumber, int pageSize, FormCollection form)
        {
            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var model = new BookingSearchViewModel(Repository, false, false);

            if (TryUpdateModel(model, form.ToValueProvider()))
            {

                var bookingDate = DateTime.Today;

                if (model.BookingDate.HasValue)
                {
                    bookingDate = model.BookingDate.Value;

                    if (time.HasValue)
                    {
                        var newTime = bookingDate;
                        newTime = newTime.AddHours(time.Value.Hour);
                        newTime = newTime.AddMinutes(time.Value.Minute);
                        time = newTime;
                    }
                }

                int itemCount;
                int pageCount;
                var items = _bookingRepository.GetBookingsForSlot(
                    technicianId,
                    bookingDate,
                    time,
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
                            hasProblem = StringFormatter.BooleanToYesNo(item.HasProblem),
                            hasLargeLadder = StringFormatter.BooleanToYesNo(item.HasLargeLadder),
                            lastServicedDate = StringFormatter.LocalDate(item.LastServicedDate),
                            nextServiceDate = StringFormatter.LocalDate(item.NextServiceDate),
                            technicianId = item.TechnicianId.ToString(),
                            technicianName = HttpUtility.HtmlEncode(item.TechnicianName ?? string.Empty),
                            bookingDate = StringFormatter.LocalDate(item.BookingDate),
                            bookingTime = StringFormatter.LocalTime(item.BookingTime),
                            duration = item.Duration.ToString(),
                            rowVersion = Convert.ToBase64String(item.RowVersion)
                        }).ToArray()
                };
                return Json(result);
            }
            else
            {
                return Json(string.Empty);
            }
        }

        [HttpGet]
        [Transactional]
        public ActionResult Edit(int id, int? propertyInfoId)
        {
            var model = new BookingViewModel(Repository, _bookingRepository, _propertyRepository, propertyInfoId, id);
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, int? propertyInfoId, FormCollection form)
        {
            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Booking"))
            {
                var model = new BookingViewModel(Repository, _bookingRepository, _propertyRepository, propertyInfoId, id);

                if (TryUpdateModel(model, "", null, new[] { "Booking.Id" }, form.ToValueProvider()))
                {

                    model.Booking.Consolidate();
                    Repository.Save(model.Booking);
                    Repository.Save(model.Booking.PropertyInfo);

                    try
                    {
                        tx.Commit();

                        ShowInfoMessage("Success", "Booking saved.");

                        if (JsWindowHelper.IsWindowToClose(this.ControllerContext))
                        {
                            TempData["CloseDialog"] = "true";
                        }
                        else
                        {
                            TempData["CloseDialog"] = "false";
                        }

                        return new ApplySaveResult("Edit", new { area = "Booking", id = model.Booking.Id, propertyInfoId = model.Booking.PropertyInfo.Id }, "Index");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "Booking"));

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
        public ActionResult Cancel(int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Cancel Booking"))
            {
                var model = new BookingCancelViewModel(Repository, _bookingRepository, id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion", "InspectionStatus", "ContactNotes" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    if (!model.InspectionStatus.HasValue)
                    {
                        return Json(new { success = false, message = "No Inspection Status selected" });
                    }
                    try
                    {
                        model.Booking.Cancel(model.InspectionStatus.Value, model.ContactNotes);
                        Repository.Save(model.Booking);
                        Repository.Save(model.Booking.PropertyInfo);

                        tx.Commit();

                    }
                    catch (DataCurrencyException)
                    {
                        return Json(new { success = false, message = string.Format(SR.DataCurrencyException_Delete_Message, "Booking") });
                    }
                    catch (EntityInUseException)
                    {
                        return Json(new { success = false, message = string.Format(SR.EntityInUseException_Delete_Message, "Booking") });
                    }
                    return Json(new { success = true, message = "Booking cancelled" });
                }
            }

            return Json(new { success = false });
        }


        [HttpPost]
        public ActionResult AllocateTechnician(IEnumerable<int> selectedRows, int? technicianId, string time, int? duration)
        {
            if (selectedRows == null)
            {
                return Json(new { success = false, message = "No rows selected" });
            }

            var userProfile = User.Identity.GetProfile();
            DateTime dateTime;
            if (DateTime.TryParse(time, out dateTime))
            {
                _bookingRepository.AllocateTechnician(selectedRows, technicianId, dateTime, duration, userProfile.Id);
            }
            else
            {
                _bookingRepository.AllocateTechnician(selectedRows, technicianId, null, duration, userProfile.Id);
            }

            return Json(new { success = true, message = "Bookings allocated" });
        }
    }
}