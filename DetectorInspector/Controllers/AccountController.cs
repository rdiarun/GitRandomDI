using System;
using System.Web.Mvc;
using System.Web.Security;

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
using DetectorInspector.Common.Notifications;

namespace DetectorInspector.Controllers
{
	[HandleError]
	public class AccountController : SiteController
	{        
		private IAuthenticationProvider _authenticationProvider;        
        private UserProfile _userProfile;

        public AccountController(
            ITransactionFactory transactionFactory,
            IAuthenticationProvider authenticationProvider, 
            IMembershipService membershipService,
            IUserRepository userRepository,
			IRepository repository,
            INotificationService notificationService,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
		{            
			_authenticationProvider = authenticationProvider;
            UserRepository = userRepository;
            NotificationService = notificationService;
            MembershipService = membershipService;
		}

        protected IMembershipService MembershipService { get; private set; }

        protected IUserRepository UserRepository { get; private set; }

        protected INotificationService NotificationService { get; private set; }

        [HttpGet]
        public ActionResult ForgottenPassword()
        {
            var model = new ForgottenPasswordViewModel();

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ForgottenPassword(FormCollection form)
        {
            var model = new ForgottenPasswordViewModel();

            if (TryUpdateModel(model, "", form.ToValueProvider()))
            {
                var userId = MembershipService.GetUserIdForUserName(model.UserName);

                //check if user exists
                if (userId.HasValue && userId != Guid.Empty)
                {
                    //get profile
                    var userProfile = UserRepository.GetProfile(userId.Value);

                    //check if locked out
                    if (userProfile.IsLockedOut || !userProfile.IsApproved)
                    {
                        ModelState.AddModelError("UserName", "Password cannot be retrieved for this account. Please contact the system administrator.");
                    }
                    else
                    {
                        //generate new password
                        var newPassword= GeneratePassword();

                        //reset password
                        MembershipService.ChangePassword(userProfile.UserName, newPassword);    

                        //send user password
                        NotificationService.SendForgottenPasswordEmail(userProfile, newPassword);
                    }
                }

                ShowInfoMessage("Success!", "An email containing your password has been sent to your registered email address.");
            }

            return View(model);
        }

        public ActionResult SignOut()
        {
            _authenticationProvider.SignOut();
			Session.Abandon();

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public ActionResult Register()
        {
            if (Request.IsAuthenticated)
            {
                //if logged in, go to profile
                return RedirectToAction("Profile");
            }
            else
            {
                var model = new RegisterViewModel(new UserProfile());

                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Register(FormCollection form)
        {            
            using (var tx = TransactionFactory.BeginTransaction("Register"))
            {
                var model = new RegisterViewModel(new UserProfile());

                if (TryUpdateModel(model, "", null, new string[] { "Id" }))
                {
                    //set profile to approved
                    model.Profile.IsApproved = true;

                    if (CreateUser(tx, MembershipService, UserRepository, model.Profile, model.Password))
                    {
                        //log user in
                        FormsAuthentication.SetAuthCookie(model.Profile.UserName, false);

                        //success message
                        ShowInfoMessage("Success", "Account created.");

                        return RedirectToAction("RegisterThankYou");
                    }
                }

                return View(model);
            }
        }

        [HttpGet]
        [Authorize]
        public ActionResult Profile()
        {
            var viewModel = new RegisterViewModel(GetUserProfile());

            return View(viewModel);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize]
        public ActionResult Profile(FormCollection form)
        {
            var viewModel = new RegisterViewModel(GetUserProfile());

            //edit user
            using (var tx = TransactionFactory.BeginTransaction("Edit User"))
            {
                var originalEmailAddress = viewModel.Profile.EmailAddress;
                var originalUserName = viewModel.Profile.UserName;


                if (TryUpdateModel(viewModel.Profile, "Profile", null, new string[] { "IsApproved", "IsLockedOut", "LastLoginUtcDate", "Roles" }, form.ToValueProvider()))
                {
                    try
                    {
                        //update username/email address
                        UpdateUserDetails(MembershipService, UserRepository, viewModel.Profile, originalEmailAddress, originalUserName);

                        //save changes (repository.save only needed when creating new)
                        tx.Commit();


                        //set username (as it may have changed)
                        FormsAuthentication.SetAuthCookie(viewModel.Profile.UserName, false);

                        ShowInfoMessage("Success", "Profile saved.");

                        return RedirectToAction("Profile");
                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Save Failed",
                            string.Format(SR.DataCurrencyException_Edit_Message, "User"));
                    }
                }

                return View(viewModel);
            }
        }

        [Authorize]
        public ActionResult RegisterThankYou()
        {            
            return View();
        }

        [Authorize]
        [ChildActionOnly]
		[Transactional]
        public ActionResult ProfileHeader()
        {
            var model = UserRepository.GetProfile(User.Identity.GetUserId().Value);

			model.LastLoginUtcDate = Session["LastLoginUtcDate"] == null ? model.CreatedUtcDate : (DateTime)Session["LastLoginUtcDate"];

            return PartialView(model);
        }


		[Authorize]
		public ActionResult ChangePassword()
		{
            ViewData["PasswordLength"] = MembershipService.MinimumPasswordLength;
            
            return View();
		}

		[Authorize]
		[HttpPost]
		public ActionResult ChangePassword(FormCollection form)
		{
            var model = new ChangePasswordViewModel();

            if (TryUpdateModel(model, "", null, new string[] { }))
            {                
                if (!MembershipService.ChangePassword(User.Identity.Name, model.ExistingPassword, model.ConfirmPassword))
                {
                    ModelState.AddModelError("_FORM", "The current password is incorrect or the new password is invalid.");
                }
                else
                {
                    ShowInfoMessage("Success", "Password changed successfully");

                    RedirectToAction("Profile");
                }
            }

            ViewData["PasswordLength"] = MembershipService.MinimumPasswordLength;

            return View(model);
		}

        protected UserProfile GetUserProfile()
        {
            if (_userProfile == null)
            {
                //get user id
                var userId = MembershipService.GetUserIdForUserName(User.Identity.Name);

                //load profile
                _userProfile = UserRepository.GetProfile(userId.Value);
            }

            return _userProfile;
        }
	}
}