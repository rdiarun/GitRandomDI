using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DetectorInspector.Model;
using System.Security.Principal;
using Microsoft.Practices.ServiceLocation;
using DetectorInspector.Data;
using Kiandra.Web.Mvc.Security;
using Kiandra.Data;

namespace DetectorInspector.Infrastructure
{
    public static class SecurityExtensions
    {
        /// <summary>
        /// Ensures that the permissions assigned to the specified user are cached within
        /// the user's session.
        /// </summary>
        public static void InitializeUserSecurityContext(this IPrincipal principal)
        {
            HasPermission(principal, Permission.AdministerSystem);
            //GetProfile(principal.Identity);
            GetUserId(principal.Identity);
        }

        /// <summary>
        /// Gets a value indicating if the user has been assigned the specified permission.
        /// </summary>
        /// 

        /// <summary>
        /// Gets a value indicating if the user has been assigned the specified permission.
        /// </summary>
        public static bool HasPermission(this IPrincipal principal, Permission permission)
        {
            Permission[] permissions = null;

            var sessionPermissions = HttpContext.Current.Session["permissionsGranted"];

            if (sessionPermissions == null)
            {
                var userRepository = ServiceLocator.Current.GetInstance<IUserRepository>();
                var transactionFactory = ServiceLocator.Current.GetInstance<ITransactionFactory>();

                using (var tx = transactionFactory.BeginTransaction())
                {
                    var userId = principal.Identity.GetUserId();

                    if (userId.HasValue)
                    {
                        permissions = userRepository.GetUserPermissions(userId.Value).ToArray();

                        tx.Commit();
                    }
                }

                HttpContext.Current.Session["permissionsGranted"] = permissions;
            }
            else
            {
                permissions = (Permission[])sessionPermissions;
            }

            if (permissions == null)
            {
                return false;
            }
            else
            {
                return permissions.Contains(Permission.AdministerSystem) || permissions.Contains(permission);
            }
        }

        //public static bool HasPermission(this IPrincipal principal, Permission permission)
        //{
        //    Permission[] permissions = null;
        //    //   Array [] ss =   "SuperPermission";
        //    string[] arr = new string[1];
        //    arr[0] = "27";
        //    string aa = "27";
        //    var sessionPermissions = HttpContext.Current.Session["permissionsGranted"];
        //    var ss = "SuperPermission";
        //    if (sessionPermissions == null)
        //    {
        //        var userRepository = ServiceLocator.Current.GetInstance<IUserRepository>();
        //        var transactionFactory = ServiceLocator.Current.GetInstance<ITransactionFactory>();

        //        using (var tx = transactionFactory.BeginTransaction())
        //        {
        //            var userId = principal.Identity.GetUserId();

        //            if (userId.HasValue)
        //            {
        //                permissions = userRepository.GetUserPermissions(userId.Value).ToArray();

        //                tx.Commit();
        //            }
        //        }

        //        HttpContext.Current.Session["permissionsGranted"] = permissions;
        //    }
        //    else
        //    {
        //        permissions = (Permission[])sessionPermissions;
        //    }

        //    if (permissions == null)
        //    {
        //        return false;
        //    }

        ////    else if (aa==permissions.Contains(permissions[8]).ToString())
        //    //else if (aa == (permissions[8].ToString ()))
        //    //{
        //    //    //   Permission per = new Permission();
        //    //    return false;
        //    //}
        //    else
        //    {
        //        return permissions.Contains(Permission.AdministerSystem) || permissions.Contains(permission);
        //    }
        //}

        public static UserProfile GetProfile(this IIdentity identity)
        {
            UserProfile result = null;

            var userProfile = HttpContext.Current.Session["userProfile"];

            if (userProfile == null)
            {
                var userId = identity.GetUserId();

                if (userId != null)
                {
                    var userRepository = ServiceLocator.Current.GetInstance<IUserRepository>();
                    var transactionFactory = ServiceLocator.Current.GetInstance<ITransactionFactory>();

                    using (var tx = transactionFactory.BeginTransaction())
                    {
                        result = userRepository.GetProfile((Guid)userId);

                    }

                    HttpContext.Current.Session.Add("userProfile", result);
                }
            }
            else
            {
                result = (UserProfile)userProfile;
            }

            return result;
        }

        public static Guid? GetUserId(this IIdentity identity)
        {
            Guid? result = null;

            if (identity.IsAuthenticated)
            {
                var userId = HttpContext.Current.Session["userId"];

                if (userId == null)
                {
                    var membershipService = ServiceLocator.Current.GetInstance<IMembershipService>();

                    result = membershipService.GetUserIdForUserName(identity.Name);

                    HttpContext.Current.Session.Add("userId", result);
                }
                else
                {
                    result = (Guid)userId;
                }
            }

            return result;
        }
    }
}
