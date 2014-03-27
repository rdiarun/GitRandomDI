using System;
using System.Configuration;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using DetectorInspector.Infrastructure;
using Elmah;
using Kiandra.Web.Mvc;
using Microsoft.Practices.ServiceLocation;
using NHibernate;
using NHibernate.Search.Event;
using StructureMap;

namespace DetectorInspector
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            var config = (ApplicationConfig)ConfigurationManager.GetSection("kiandra");

            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
            routes.IgnoreRoute("{*favicon}", new { favicon = @"(.*/)?favicon.ico(/.*)?" });

            routes.MapRoute(
                "Default",                                              // Route name
                "{controller}" + config.MvcFileExtension + "/{action}/{id}",                           // URL with parameters
                new { controller = "Home", action = "Index", id = "" }, // Parameter defaults
                new[] { "DetectorInspector.Controllers" }
            );

            //RouteDebug.RouteDebugger.RewriteRoutesForTesting(routes);
        }


        private ISessionFactory _sessionFactory;

        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            RegisterRoutes(RouteTable.Routes);

            InitializeHibernate();

            //InitializeValidationFramework();

            InitializeServiceLocator(this.GetType().BaseType.Namespace);

            //HibernatingRhinos.Profiler.Appender.NHibernate.NHibernateProfiler.Initialize();

            InitializeModelBinders();

            ControllerBuilder.Current.SetControllerFactory(
                new CoreControllerFactory(ServiceLocator.Current));
        }

        private void InitializeHibernate()
        {
            var config = new NHibernate.Cfg.Configuration();

            config.Configure();

            //Add NHibernate.Search listeners
            config.SetListener(NHibernate.Event.ListenerType.PostUpdate, new FullTextIndexEventListener());
            config.SetListener(NHibernate.Event.ListenerType.PostInsert, new FullTextIndexEventListener());
            config.SetListener(NHibernate.Event.ListenerType.PostDelete, new FullTextIndexEventListener());

            _sessionFactory = config.BuildSessionFactory();


        }


        //private void InitializeValidationFramework()
        //{
        //    //var resourceManager = new ResourceManager(typeof(ValidationMessages));

        //    //_validatorRegistry = new CachedLocalizedValidatorRegistry(resourceManager);
        //    _validatorRegistry = new CachedLocalizedValidatorRegistry();

        //    var browserValidationEngine =
        //        new BrowserValidationEngine(_validatorRegistry, new JQueryValidator());

        //    ValidationEngineAccessor.Current.SetValidationEngine(browserValidationEngine);
        //}

        private void InitializeServiceLocator(string baseNamespace)
        {
            var container = new Container(registry =>
            {
                registry.ForRequestedType<ISessionFactory>()
                    .AsSingletons()
                    .TheDefault.IsThis(_sessionFactory);

                //registry.ForRequestedType<IValidatorRegistry>()
                //    .TheDefault.Is.IsThis(_validatorRegistry);

                registry.AddRegistry<CoreRegistry>();
            });

            var serviceLocator = new StructureMapServiceLocator(container);

            ServiceLocator.SetLocatorProvider(() => serviceLocator);

            container.Configure(ce =>
            {
                ce.ForRequestedType<IServiceLocator>().TheDefault.IsThis(serviceLocator);
            });
        }

        private void InitializeModelBinders()
        {
            global::System.Web.Mvc.ModelBinders.Binders.DefaultBinder =
                ServiceLocator.Current.GetInstance<CoreModelBinder>();

            // TODO: Add the applications custom model binders here
            // eg. global::System.Web.Mvc.ModelBinders.Binders.Add(typeof(UserProfile), serviceLocator.GetInstance<ProfileModelBinder>());
        }

        void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();

            if (ex is HttpRequestValidationException)
            {
                Response.Clear();
                Response.StatusCode = 200;
                Response.Write(@"<html><head><title>HTML Not Allowed</title><script language='JavaScript'><!--function back() { history.go(-1); } //--></script></head><body style='font-family: Arial, Sans-serif;'><h1>Oops!</h1><p>I'm sorry, but HTML entry is not allowed on that page.</p><p>Please make sure that your entries do not contain any angle brackets like &lt; or &gt;.</p><p></p></body></html>");
                Response.End();
            }

        }


        //protected void Session_Start()
        //{
        //    if (Context.Session != null)
        //    {
        //        if (Context.Session.IsNewSession)
        //        {
        //            string sCookieHeader = Request.Headers["Cookie"];
        //            if ((null != sCookieHeader) && (sCookieHeader.IndexOf("ASP.NET_SessionId") >= 0))
        //            {
        //                // how to simulate it ???
        //                RedirectResult();
        //            }


        //        }
        //    }
        //}

        //public class HandleSessionTimeoutAttribute : ActionFilterAttribute
        //{
        //    public override void OnActionExecuting(FilterExecutingContext filterContext)
        //    {
        //        // Do whatever it is you want to do here.
        //        // The controller and request contexts, along with a whole lot of other
        //        // stuff, is available on the filter context.
        //    }
        //}
        //protected void Application_Start()
        //{
        //    AreaRegistration.RegisterAllAreas();

        //    // Register global filter
        //    GlobalFilters.Filters.Add(new HandleSessionTimeoutAttribute());

        //    RegisterGlobalFilters(GlobalFilters.Filters);
        //    RegisterRoutes(RouteTable.Routes);
        //}

        //public  void OnActionExecuting(ActionExecutingContext filterContext)
        //{
        //    HttpContext ctx = HttpContext.Current;

        //    // check if session is supported
        //    if (ctx.Session != null)
        //    {
        //        // check if a new session id was generated
        //        if (ctx.Session.IsNewSession)
        //        {

        //            if (!filterContext.HttpContext.Request.IsAjaxRequest())
        //            {
        //                string sessionCookie = ctx.Request.Headers["Cookie"];
        //                if ((null != sessionCookie) && (sessionCookie.IndexOf("ASP.NET_SessionId") >= 0))
        //                {
        //                    var viewData = filterContext.Controller.ViewData;
        //                    //viewData.Model = username;
        //                    filterContext.HttpContext.Response.StatusCode = 504;
        //                    //filterContext.Result = new ViewResult { ViewName = "/Home/SessionExpire.aspx", ViewData = viewData };  

        //                    //ctx.Response.Redirect("~/Home/Login");
        //                   // ctx.Response.Redirect("~/Home/SessionExpire");
        //                    ctx.Response.Redirect("~/Home/Index");
        //                }

        //            }


        //        }
        //    }

        //  //  base.OnActionExecuting(filterContext);
        //}


        protected void Session_Start(object sender, EventArgs e)
        {
            Session["LastLoginUtcDate"] = DateTime.Now;
        }


        //[AttributeUsage(AttributeTargets.Method, Inherited = true, AllowMultiple = false)]
        //public class SessionCheckAttribute : ActionFilterAttribute
        //{
        //    public override void OnActionExecuting(System.Web.Mvc.ActionExecutingContext filterContext)
        //    {
        //        string controllerName = filterContext.ActionDescriptor.ControllerDescriptor.ControllerName.ToLower();
        //        HttpSessionStateBase session = filterContext.HttpContext.Session;
        //        var activeSession = session["LastLoginUtcDate"];
        //        if (activeSession == null)
        //        {
        //            //Redirect
        //            var url = new UrlHelper(filterContext.RequestContext);
        //            var loginUrl = url.Content("~/Error/SessionTimeout");
        //            filterContext.HttpContext.Response.Redirect(loginUrl, true);
        //        }

        //    }
        //}
    }
}