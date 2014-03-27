using System;
using System.Linq;
using System.Web.Mvc;
using System.Web.Security;
using DetectorInspector.Common.Formatters;
using Kiandra.Data;
using Kiandra.Web.Mvc;
using Kiandra.Web.Mvc.Security;

using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Web;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;

namespace DetectorInspector.Controllers
{
    [HandleError]

    //  [RequirePermission(Permission.AdministerSystem)]
    // [RequirePermission(Permission.SuperPermission)]
    public class HomeController : SiteController
    {
        private IAuthenticationProvider _authenticationProvider;
        private IMembershipService _membershipService;
        private IUserRepository _userRepository;
        private IPropertyRepository _propertyRepository;

        public HomeController(
            ITransactionFactory transactionFactory,
            IAuthenticationProvider authenticationProvider,
            IMembershipService membershipService,
            IUserRepository userRepository,
            IRepository repository,
            IPropertyRepository propertyRepository,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _authenticationProvider = authenticationProvider;
            _membershipService = membershipService;
            _userRepository = userRepository;
            _propertyRepository = propertyRepository;
        }


        [HttpGet]
        public ActionResult Error()
        {
            return View();
        }

        [HttpGet]
        public ActionResult NotImplemented()
        {
            return View();
        }

        [HttpGet]
        public ActionResult Index()
        {
            if (User.Identity.IsAuthenticated)
            {
                return RedirectToAction("Index", "Home", new { area = "PropertyInfo" });
            }
            if (User.Identity.IsAuthenticated==false)
            {
                var loginmodel = new LoginViewModel();
                return View(loginmodel);
            }
            var model = new LoginViewModel();
            return View(model);
        }

        [HttpPost]
        public ActionResult Index(FormCollection form, string returnUrl)
        {
            var model = new LoginViewModel();

            if (TryUpdateModel(model, "", form.ToValueProvider()))
            {
                var lastLoginUtcDate = _membershipService.GetLastLoginUtcDate(model.UserName);

                if (_membershipService.ValidateUser(model.UserName, model.Password))
                {
                    _authenticationProvider.SignIn(model.UserName, false);

                    Session.Add("LastLoginUtcDate", lastLoginUtcDate);

                    if (!string.IsNullOrEmpty(returnUrl))
                    {
                        return Redirect(returnUrl);
                    }
                    else
                    {
                        //  return Redirect("PropertyInfo");
                        return Redirect("PropertyInfo/Home");
                        // return RedirectToAction("Dashboard");
                    }
                }
                else
                {
                    ModelState.AddModelError("Login Failed", "The user name or password provided is incorrect.");
                }
            }

            return View(model);
        }

        [HttpGet]
        //    [RequirePermission(Permission.SuperPermission)]
        public ActionResult Dashboard()
        {
            var viewModel = new UserProfileViewModel(_userRepository.GetProfile(User.Identity.GetUserId().Value));
            return View(viewModel);
        }

        [HttpPost]
        public ActionResult FindProperty(string keywords, bool quickSearch)
        {
            int itemCount;
            int pageCount;

            var items = _propertyRepository.Find(keywords, quickSearch, out itemCount, out pageCount);

            if (itemCount > 0)
            {
                if (itemCount == 1)
                {
                    var id = from item in items
                             select item.Id;

                    ShowInfoMessage("Success", "Property was successfully found.");
                    return Json(new { success = true, id = id, itemCount = itemCount });
                }

                var result = new
                                 {
                                     pageCount = pageCount,
                                     pageNumber = 1,
                                     itemCount = itemCount,
                                     items = (
                                                 from item in items
                                                 select new
                                                            {
                                                                id = item.Id.ToString(),
                                                                propertyNumber = item.PropertyNumber.ToString(),
                                                                unitShopNumber = HttpUtility.HtmlEncode(item.UnitShopNumber ?? string.Empty),
                                                                streetNumber = HttpUtility.HtmlEncode(item.StreetNumber ?? string.Empty),
                                                                streetName = HttpUtility.HtmlEncode(item.StreetName ?? string.Empty),
                                                                state = HttpUtility.HtmlEncode(item.State ?? string.Empty),
                                                                suburb = HttpUtility.HtmlEncode(item.Suburb ?? string.Empty),
                                                                postCode = HttpUtility.HtmlEncode(item.PostCode ?? string.Empty),
                                                                inspectionStatusEnum = HttpUtility.HtmlEncode(item.InspectionStatusEnum.ToString()),
                                                                inspectionStatus = item.IsCancelled ? "Cancelled" : HttpUtility.HtmlEncode(item.InspectionStatus),
                                                                electricalWorkStatusEnum = HttpUtility.HtmlEncode(item.ElectricalWorkStatusEnum.ToString()),
                                                                electricalWorkStatus = HttpUtility.HtmlEncode(item.ElectricalWorkStatus),
                                                                agencyName = HttpUtility.HtmlEncode(item.AgencyName ?? string.Empty),
                                                                propertyManager = HttpUtility.HtmlEncode(item.PropertyManager ?? string.Empty),
                                                                keyNumber = HttpUtility.HtmlEncode(item.KeyNumber ?? string.Empty),
                                                                tenantName = HttpUtility.HtmlEncode(item.TenantName ?? string.Empty),
                                                                tenantContactNumber = HttpUtility.HtmlEncode(item.TenantContactNumber ?? string.Empty),
                                                                hasProblem = StringFormatter.BooleanToYesNo(item.HasProblem),
                                                                hasLargeLadder = StringFormatter.BooleanToYesNo(item.HasLargeLadder),
                                                                lastServicedDate = item.LastServicedDate == null ? "Unknown" : StringFormatter.LocalDate(item.LastServicedDate.Value),
                                                                nextServiceDate = string.Format("<div class=\"due-{0}\">{1}</div>", DueDateFormatter.FormatNextDueDate(item).ToLower(), item.NextServiceDate == null ? string.Empty : StringFormatter.LocalDate(item.NextServiceDate.Value)),
                                                                rowVersion = Convert.ToBase64String(item.RowVersion)
                                                            }).ToArray()
                                 };

                return Json(result);
            }

            ModelState.AddModelError("Not Found", "Property could not be found.");
            return Json(new { itemCount = 0 });
        }

        //Can be refactored into a single class.Repeated in two controllers.


    }
}