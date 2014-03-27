using System;
using System.Web.Mvc;
using System.Security;
using System.Web.Security;
using System.Web;

using DetectorInspector.Model;

namespace DetectorInspector.Infrastructure
{
    [AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, Inherited = true, AllowMultiple = true)]
    public class RequirePermissionAttribute : FilterAttribute, IAuthorizationFilter
    {
        private Permission _requiredPermission;

        public RequirePermissionAttribute(Permission requiredPermission)
        {
            _requiredPermission = requiredPermission;
        }

        public Permission RequiredPermission
        {
            get { return _requiredPermission; }
        }

        protected virtual bool AuthorizeCore(HttpContextBase httpContext)
        {
            if (httpContext == null)
            {
                throw new ArgumentNullException("httpContext");
            }
            
            var user = httpContext.User;

            if (!user.Identity.IsAuthenticated)
            {
                return false;
            }

            if (!user.HasPermission(_requiredPermission))
            {
				return false;
            }

            return true;
        }

        private void CacheValidateHandler(HttpContext context, object data, ref HttpValidationStatus validationStatus)
        {
            validationStatus = OnCacheAuthorization(new HttpContextWrapper(context));
        }

        protected virtual void HandleUnauthorizedRequest(AuthorizationContext filterContext)
        {
            filterContext.Result = new HttpUnauthorizedResult();
        }

        public virtual void OnAuthorization(AuthorizationContext filterContext)
        {
            if (filterContext == null)
            {
                throw new ArgumentNullException("filterContext");
            }

            if (AuthorizeCore(filterContext.HttpContext))
            {
                var cache = filterContext.HttpContext.Response.Cache;

                cache.SetProxyMaxAge(new TimeSpan(0));
                cache.AddValidationCallback(new HttpCacheValidateHandler(CacheValidateHandler), null);
            }
            else
            {
                HandleUnauthorizedRequest(filterContext);
            }
        }

        protected virtual HttpValidationStatus OnCacheAuthorization(HttpContextBase httpContext)
        {
            if (httpContext == null)
            {
                throw new ArgumentNullException("httpContext");
            }
            
            if (!AuthorizeCore(httpContext))
            {
                return HttpValidationStatus.IgnoreThisRequest;
            }

            return HttpValidationStatus.Valid;
        }
   }


}
