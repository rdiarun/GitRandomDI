using System;
using System.Web.Mvc;
using DetectorInspector.Data;
using Kiandra.Data;

namespace DetectorInspector.Controllers
{
	[Authorize]
	public class DebugController : SiteController
	{
	    public DebugController(ITransactionFactory transactionFactory, 
                               IRepository repository,
                               IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
		{
		}

		public ActionResult TestNotification(DateTime dueBy)
		{

			//_notificationService.SendNotifications(_log, dueBy);

			return Content("Success");
		}
	}
}
