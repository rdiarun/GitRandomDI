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
using Kiandra.Web.Mvc.Security;

namespace DetectorInspector.Areas.Technician.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AccessTechnicianDashboard)]
    public class HomeController : SiteController
    {
        private ITechnicianRepository _technicianRepository;
        protected IMembershipService MembershipService { get; private set; }

        protected IUserRepository UserRepository { get; private set; }


        public HomeController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            ITechnicianRepository technicianRepository,
            IUserRepository userRepository,
            IMembershipService membershipService,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            MembershipService = membershipService;
            UserRepository = userRepository;
            _technicianRepository = technicianRepository;    
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

            var items = Repository.GetActive<DetectorInspector.Model.Technician>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        company = HttpUtility.HtmlEncode(item.Company),
                        name = HttpUtility.HtmlEncode(item.Name),
                        telephone = HttpUtility.HtmlEncode(item.Telephone),
                        mobile = HttpUtility.HtmlEncode(item.Mobile),
                        isApproved = StringFormatter.BooleanToYesNo(_technicianRepository.GetProfile(item.Id).IsApproved),
                        isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
                    }).ToArray()
            };

            return Json(result);
        }



        [HttpGet]        
        [Transactional]
        public ActionResult Edit(int id)
        {
            var model = new TechnicianViewModel(Repository, _technicianRepository, id);

            return View(model);
        }

        [HttpPost]        
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, FormCollection form)
        {


            bool isCreated = id == 0;
            var action = isCreated ? "Create" : "Edit";

            using (var tx = TransactionFactory.BeginTransaction(action + " Technician"))
            {
                var model = new TechnicianViewModel(Repository, _technicianRepository, id);
                var originalEmailAddress = model.Profile.EmailAddress;
                var originalUserName = model.Profile.UserName;

                if (isCreated)
                {
                    if (!TryUpdateModel(model, "", null, new[] { "Technician.Id" }, form.ToValueProvider()))
                    {
                        return View(model);
                    }
                }

                if (model.Password!=null && model.Password.Length < 8)
                {
                    ShowValidationErrorMessage("Password", "Password must be at least 8 characters long.");

                    return View(model);
                }

                if(TryUpdateModel(model.Technician, "Technician", null, new [] { "Technician.Id" }, form.ToValueProvider()))
                {

                    if (TryUpdateModel(model.Profile, "Profile", form.ToValueProvider()))
                    {
                        if (UserRepository.UserExists(model.Profile.FirstName, model.Profile.LastName, model.Profile.Id))
                        {
                            ModelState.AddModelError("_FORM", "There is already a user with this first name and last name.");
                            return View(model);
                        }

                        var userId = MembershipService.GetUserIdForUserName(model.Profile.UserName);

                        if (userId != null && userId != Guid.Empty && userId != model.Profile.Id)
                        {
                            ModelState.AddModelError("_FORM", "Username already exists.");
                            return View(model);
                        }
                        
                        model.UpdateModel();
                        Repository.Save(model.Technician);

                        try
                        {
                            model.Profile.Technician = model.Technician;

                            if (model.Profile.Id.Equals(Guid.Empty))
                            {
                                //create user
                                CreateUser(tx, MembershipService, UserRepository, model.Profile, model.Password);
                            }
                            else
                            {

                                try
                                {
                                    //update username/email address
                                    UpdateUserDetails(MembershipService, UserRepository, model.Profile, originalEmailAddress, originalUserName);

                                    //save changes (repository.save only needed when creating new)
                                    tx.Commit();

                                    //approve/unapprove user
                                    ApproveUnapproveUser(model.Technician, model.Profile);

                                }
                                catch (DataCurrencyException)
                                {
                                    ShowErrorMessage("Save Failed",
                                        string.Format(SR.DataCurrencyException_Edit_Message, "Technician"));
                                }
                            }
                            ShowInfoMessage("Success", "Technician saved.");

                            return new ApplySaveResult("Edit", new { id = model.Technician.Id }, "Index");
                        }
                        catch (DataCurrencyException)
                        {
                            ShowErrorMessage("Save Failed",
                                string.Format(SR.DataCurrencyException_Edit_Message, "Technician"));

                            return View(model);
                        }
                    }
                    else
                    {
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
        public ActionResult Bookings(int technicianId, string date)
        {

            var model = _technicianRepository.Get(technicianId);
            var viewModel = new BookingsViewModel(model, DateTime.Parse(date));
            return View(viewModel);

        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete Technician"))
            {
                var model = Repository.Get<DetectorInspector.Model.Technician>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        model.IsDeleted = true;
                        model.Cancel();
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Technician deleted.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Technician"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Technician not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "Technician"));
                    }
                }
            }

            return RedirectToAction("Index");
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Cancel(int id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Cancel Technician"))
            {
                var model = _technicianRepository.Get(id);
                var profile = _technicianRepository.GetProfile(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        profile.IsApproved = false;
                        ApproveUnapproveUser(model, profile);
                        Repository.Save(model);

                        tx.Commit();

                        ShowInfoMessage("Success", "Technician cancelled.");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Cancel Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "Technician"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("Technician not cancelled",
                            string.Format(SR.EntityInUseException_Delete_Message, "Technician"));
                    }
                }
            }

            return RedirectToAction("Index");
        }

        protected void ApproveUnapproveUser(DetectorInspector.Model.Technician technician, UserProfile profile)
        {
            //check whether to approve or unapprove user (using email as *new username)
            if (profile.IsApproved)
            {
                MembershipService.ApproveUser(profile.UserName);
            }
            else
            {
                MembershipService.UnapproveUser(profile.UserName);
                technician.Cancel();
            }
        }


        [HttpGet]
        public ActionResult ServicesByZone(int monthToAdd)
        {
            var viewModel = new ServicesByZoneViewModel(_technicianRepository, DateTime.Today.AddMonths(monthToAdd));
            return View(viewModel);
        }

        [HttpPost]
        public ActionResult UnlockAccount(Guid id)
        {
            var user = UserRepository.GetProfile(id);
            var technician = user.Technician;
            var success = false;

            if (technician != null)
            {
                success = MembershipService.UnlockUser(user.UserName);
            }

            return Json(new { success = success });
        }

    }
}