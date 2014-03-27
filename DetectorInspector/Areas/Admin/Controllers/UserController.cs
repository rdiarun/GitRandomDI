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
using Kiandra.Web.Mvc.Security;
using System.Web.Security;
using System.Threading;
using DetectorInspector.Common.Notifications;

namespace DetectorInspector.Areas.Admin.Controllers
{
    [HandleError]
 /// [RequirePermission(Permission.AdministerSystem)]
    public class UserController : SiteController
    {
         public UserController(
            ITransactionFactory transactionFactory,
            IRepository repository,
			IMembershipService membershipService,
            IUserRepository userRepository,
            INotificationService notificationService,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {            
            UserRepository = userRepository;
			MembershipService = membershipService;
            NotificationService = notificationService;
        }

        protected IMembershipService MembershipService { get; private set; }

        protected IUserRepository UserRepository { get; private set; }

        protected INotificationService NotificationService { get; private set; }

        [HttpGet]
        [Transactional]
        public ActionResult Index()
        {
            var viewModel = new UserSearchViewModel(Repository, false);

            return View(viewModel);
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetItems(string sortBy, string sortDirection, int pageNumber, int pageSize, FormCollection form)
        {
            int itemCount;
            int pageCount;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var viewModel = new UserSearchViewModel(Repository, true);

			if (TryUpdateModel(viewModel, form.ToValueProvider()))
			{
                var items = UserRepository.Search(
					viewModel.SelectedRoles, 
					viewModel.Enabled,
					viewModel.LockedOut,
					pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
							firstName = HttpUtility.HtmlEncode(item.FirstName),
							lastName = HttpUtility.HtmlEncode(item.LastName),
                            userName = HttpUtility.HtmlEncode(item.UserName),
							email = HttpUtility.HtmlEncode(item.EmailAddress),
                            rowVersion = Convert.ToBase64String(GetUserProfile(item.Id).RowVersion),
							isApproved = StringFormatter.BooleanToYesNo(item.IsApproved),
							isLockedOut = StringFormatter.BooleanToYesNo(item.IsLockedOut),
                            isSystem = StringFormatter.BooleanToYesNo(GetUserProfile(item.Id).IsSystem),
							lastLoginUtcDate = StringFormatter.UtcToLocalDateTime(item.LastLoginUtcDate)
						}).ToArray()
				};

				return Json(result);
			}

			return Json("");
        }
	

        [HttpGet]    
        [Transactional]
        public ActionResult Edit(Guid? id)
        {
            var viewModel = new EditUserViewModel(GetUserProfile(id), Repository); 

            return View(viewModel);
        }

		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Edit(Guid? id, FormCollection form)
		{
            var viewModel = new EditUserViewModel(GetUserProfile(id), Repository);

            if (!id.HasValue || id.Value == Guid.Empty)
            {
                //create user
                using (var tx = TransactionFactory.BeginTransaction("Create User"))
                {
                    if (TryUpdateModel(viewModel, form.ToValueProvider()))
                    {
                        if (CreateUser(tx, MembershipService, UserRepository, viewModel.Profile, viewModel.Password))
                        {                           
                            //success message
                            ShowInfoMessage("Success", "User created.");


                            return RedirectToAction("Edit", new { id = viewModel.Profile.Id});
                        }
                    }
                }
            }
            else
            {
                //edit user
                using (var tx = TransactionFactory.BeginTransaction("Edit User"))
                {                  
                    var originalEmailAddress = viewModel.Profile.EmailAddress;
                    var originalUserName = viewModel.Profile.UserName;


                    if (TryUpdateModel(viewModel.Profile, "Profile", form.ToValueProvider()))
                    {
                        try
                        {
                            //update username/email address
                            UpdateUserDetails(MembershipService, UserRepository, viewModel.Profile, originalEmailAddress, originalUserName);

                            //save changes (repository.save only needed when creating new)
                            tx.Commit();

                            //approve/unapprove user
                            ApproveUnapproveUser(viewModel.Profile);

                            ShowInfoMessage("Success", "User saved.");

                            return new ApplySaveResult("Edit", new { id = viewModel.Profile.Id }, "Index");
                        }
                        catch (DataCurrencyException)
                        {
                            ShowErrorMessage("Save Failed",
                                string.Format(SR.DataCurrencyException_Edit_Message, "User"));                           
                        }
                    }                   
                }
            }


            return View(viewModel);
		}

        private UserProfile GetUserProfile(Guid? id)
        {
            return id.HasValue && id.Value != Guid.Empty ? UserRepository.GetProfile(id.Value) : new UserProfile();
        }

		[HttpPost]
		public ActionResult UnlockAccount(Guid id)
		{
			var username = MembershipService.GetUserNameForUserId(id);

			var unlockSucceeded = MembershipService.UnlockUser(username);

			return Json(new { success = unlockSucceeded });
		}

        
        public ActionResult ResetPassword(Guid id)
        {           
            UserProfile userProfile;
            string newPassword;

            //get profile
            userProfile = UserRepository.GetProfile(id);
                        
            //generate new password
            newPassword = GeneratePassword();

            //reset password
            MembershipService.ChangePassword(MembershipService.GetUserNameForUserId(id), newPassword);
                       
            //send user password
            NotificationService.SendPasswordResetEmail(userProfile, newPassword);

            //success message
            ShowInfoMessage("Success", "Password has been reset.");

            return RedirectToAction("Edit", new { id = id });
        }

        public ActionResult ChangePassword(Guid id)
        {
            return View(new ChangeUserPasswordViewModel(GetUserProfile(id)));
        }

        [HttpPost]        
        [ValidateAntiForgeryToken]
        public ActionResult ChangePassword(Guid id, FormCollection form)
        {
            //edit user
            using (var tx = TransactionFactory.BeginTransaction("Change User Password"))
            {
                var viewModel = new ChangeUserPasswordViewModel(GetUserProfile(id));

                try
                {
                    if (TryUpdateModel(viewModel, null, null, new string[] { "Profile" }))
                    {
                        //change password
                        MembershipService.ChangePassword(viewModel.Profile.UserName, viewModel.Password);

                        //save changes (repository.save only needed when creating new)
                        tx.Commit();

                        ShowInfoMessage("Success", "Password changed.");

                        return new ApplySaveResult("Edit", new { id = viewModel.Profile.Id }, "Index");

                    }
                }
                catch (DataCurrencyException)
                {
                    ShowErrorMessage("Save Failed",
                        string.Format(SR.DataCurrencyException_Edit_Message, "User"));
                }

                return View(viewModel);
            }
        }        

        protected void ApproveUnapproveUser(UserProfile profile)
        {
            //check whether to approve or unapprove user (using email as *new username)
            if (profile.IsApproved)
            {
                MembershipService.ApproveUser(profile.UserName);
            }
            else
            {
                MembershipService.UnapproveUser(profile.UserName);
            }
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(Guid id, FormCollection form)
        {
            using (var tx = TransactionFactory.BeginTransaction("Delete User"))
            {
                var model = Repository.Get<UserProfile>(id);

                if (TryUpdateModel(model, "", new string[] { "RowVersion" }, new string[] { "Id" }, form.ToValueProvider()))
                {
                    try
                    {
                        if (!model.IsSystem)
                        {
                            model.IsDeleted = true;
                            Repository.Save<UserProfile>(model);
                            tx.Commit();
                            ShowInfoMessage("Success", "User deleted.");
                        }
                        else
                        {
                            ShowInfoMessage("Error", "User cannot be deleted - system user");
                        }

                    }
                    catch (DataCurrencyException)
                    {
                        ShowErrorMessage("Delete Failed",
                            string.Format(SR.DataCurrencyException_Delete_Message, "User"));
                    }
                    catch (EntityInUseException)
                    {
                        ShowInfoMessage("User not deleted",
                            string.Format(SR.EntityInUseException_Delete_Message, "User"));
                    }
                }
            }

            return RedirectToAction("Index");
        }

    }
}