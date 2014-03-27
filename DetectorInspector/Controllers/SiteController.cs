using System;
using DetectorInspector.ViewModels;
using DetectorInspector.Infrastructure;
using System.Web.Mvc;
using Kiandra.Web.Mvc.Security;
using DetectorInspector.Data;
using Kiandra.Data;
using DetectorInspector.Model;
using System.Web.Security;
using Kiandra.Entities;
using System.Web;


namespace DetectorInspector.Controllers
{
    public abstract class SiteController : Kiandra.Web.Mvc.Controller
    {
        public SiteController(ITransactionFactory transactionFactory, IRepository repository, IHelpRepository helpRepository)
        {
            TransactionFactory = transactionFactory;
            Repository = repository;
            HelpRepository = helpRepository;
        }

        protected ITransactionFactory TransactionFactory { get; private set; }

        protected IRepository Repository { get; private set; }

        protected IHelpRepository HelpRepository { get; private set; }

        [HttpGet]
        public ActionResult PageHelp()
        {
            //get unique name for page
            string pageCode = (RouteData.DataTokens["Area"] + "-" + RouteData.Values["Controller"] + "-" + RouteData.Values["Action"]).ToLower();

            //check whether any help exists
            var viewModel = new PageHelpViewModel(HelpRepository.GetHelp(pageCode) ?? new Help(), pageCode);

            return View(viewModel);
        }

        //protected override void OnActionExecuting(ActionExecutingContext filterContext)
        //{
        //    var user = filterContext.HttpContext.User;

        //    if (user != null && user.Identity.IsAuthenticated)
        //    {
        //        SecurityExtensions.InitializeUserSecurityContext(filterContext.HttpContext.User);
        //    }

        //    HttpSessionStateBase session = filterContext.HttpContext.Session;
        //    var activeSession = session["LastLoginUtcDate"];
        //    if (activeSession == null)
        //    {
        //        Redirect
        //        var url = new UrlHelper(filterContext.RequestContext);
        //        var loginUrl = url.Content("~/Home/Index");
        //        filterContext.HttpContext.Response.Redirect(loginUrl, true);
        //    }
        // HttpContext ctx = new  HttpContext ;

        //// check if session is supported
        //if (ctx.Session != null)
        //{
        //    // check if a new session id was generated
        //    if (ctx.Session.IsNewSession)
        //    {

        //        if (!filterContext.HttpContext.Request.IsAjaxRequest())
        //        {
        //            string sessionCookie = ctx.Request.Headers["Cookie"];
        //            if ((null != sessionCookie) && (sessionCookie.IndexOf("ASP.NET_SessionId") >= 0))
        //            {
        //                var viewData = filterContext.Controller.ViewData;
        //                //viewData.Model = username;
        //                filterContext.HttpContext.Response.StatusCode = 504;
        //                //filterContext.Result = new ViewResult { ViewName = "/Home/SessionExpire.aspx", ViewData = viewData };  

        //                //ctx.Response.Redirect("~/Home/Login");
        //                // ctx.Response.Redirect("~/Home/SessionExpire");
        //                ctx.Response.Redirect("~/Home/Index");
        //            }

        //        }
        //    }
        //}

        //       base.OnActionExecuting(filterContext);
        //   }


        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var user = filterContext.HttpContext.User;
            if (user != null && user.Identity.IsAuthenticated)
            {
                SecurityExtensions.InitializeUserSecurityContext(filterContext.HttpContext.User);

                base.OnActionExecuting(filterContext);
            }
            if (user != null && user.Identity.IsAuthenticated == false)
            {
                Session.Abandon();
                RedirectToAction("Index", "Home", new { area = "" });
            }
        }
        public void ShowInfoMessage(string title, string htmlBody)
        {
            var message = new NotificationMessage()
            {
                MessageType = NotificationMessageType.Information,
                Title = title,
                Body = htmlBody
            };

            TempData["NotificationMessage"] = message;
        }

        public void ShowErrorMessage(string title, string htmlBody)
        {
            var message = new NotificationMessage()
            {
                MessageType = NotificationMessageType.Error,
                Title = title,
                Body = htmlBody
            };

            TempData["NotificationMessage"] = message;
        }

        public void ShowValidationErrorMessage(string key, string message)
        {
            ModelState.AddModelError(key, message);
        }


        protected bool CreateUser(ITransaction tx,
                                    IMembershipService membershipService,
                                    IUserRepository userRepository,
                                    UserProfile userProfile,
                                    string password)
        {
            var userName = userProfile.UserName;

            if (userRepository.UserExists(userProfile.FirstName, userProfile.LastName))
            {
                ModelState.AddModelError("_FORM", "There is already a user with this first name and last name.");
                return false;
            }

            var userId = membershipService.GetUserIdForUserName(userProfile.UserName);

            if (userId != null && userId != Guid.Empty)
            {
                ModelState.AddModelError("_FORM", "Username already exists.");
                return false;
            }

            MembershipCreateStatus createStatus =
            membershipService.CreateUser(userName, password, userProfile.EmailAddress, userProfile.IsApproved);

            if (createStatus == MembershipCreateStatus.Success)
            {
                try
                {
                    //assign userid to profile
                    userProfile.SetUserId(membershipService.GetUserIdForUserName(userName).Value);

                    Repository.Save(userProfile);

                    tx.Commit();
                }
                catch
                {
                    membershipService.DeleteUser(userName);

                    throw;
                }

                return true;
            }
            else
            {
                ModelState.AddModelError("_FORM", createStatus.ToString());

                return false;
            }
        }

        protected string GeneratePassword()
        {
            char[] pwdNonAlhpaArray = "~!@#$%^&*()=".ToCharArray();
            string password;

            //Get a GUID
            string guid = System.Guid.NewGuid().ToString();

            //Remove  hyphens
            guid = guid.Replace("-", string.Empty);

            // Return the first length bytes
            password = guid.Substring(0, Membership.MinRequiredPasswordLength);

            //add non alpha characters
            for (int i = 0; i < Membership.MinRequiredNonAlphanumericCharacters; i++)
            {
                password += pwdNonAlhpaArray[RandomNumber(0, pwdNonAlhpaArray.Length - 1)];
            }

            return password;
        }

        private int RandomNumber(int min, int max)
        {
            Random random = new Random();
            return random.Next(min, max);
        }


        protected void UpdateUserDetails(
            IMembershipService membershipService,
            IUserRepository userRepository,
            UserProfile userProfile,
            string originalEmail,
            string originalUserName)
        {
            //check whether to update email address ( do this first so transaction does not lock member record)
            if (userProfile.EmailAddress != originalEmail)
            {
                membershipService.ChangeEmailAddress(originalUserName, userProfile.EmailAddress);
            }

            if (userProfile.UserName != originalUserName)
            {
                //update username
                userRepository.UpdateUsername(userProfile.Id, userProfile.UserName);
            }
        }

        protected TModel GetModel<TModel>(Guid? id)
            where TModel : class, IEntity, new()
        {
            return id.HasValue && id.Value != Guid.Empty ? Repository.Get<TModel>(id.Value) : new TModel();
        }

        protected TModel GetModel<TModel>(int? id)
            where TModel : class, IEntity, new()
        {
            return id.HasValue && id.Value > 0 ? Repository.Get<TModel>(id.Value) : new TModel();
        }
    }
}
