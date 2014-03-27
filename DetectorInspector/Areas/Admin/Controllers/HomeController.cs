using System.Web.Mvc;
using DetectorInspector.Controllers;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using Kiandra.Data;

namespace DetectorInspector.Areas.Admin.Controllers
{
	[HandleError]
    [RequirePermission(Permission.AdministerSystem)]
    public class HomeController : SiteController
    {
        public HomeController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
		{
		}

        public ActionResult Index()
        {
            return View();
        }
    }
}
