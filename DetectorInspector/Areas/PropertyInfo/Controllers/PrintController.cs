using System.Web.Mvc;
using DetectorInspector.Areas.PropertyInfo.ViewModels;
using DetectorInspector.Common.Notifications;
using DetectorInspector.Controllers;
using DetectorInspector.Data;
using DetectorInspector.Model;
using Kiandra.Data;
using Kiandra.Web.Mvc;

namespace DetectorInspector.Areas.PropertyInfo.Controllers
{
    [HandleError]
    public class PrintController : SiteController
    {
        private readonly INotificationTemplateEngine _templateEngine;

        public PrintController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            INotificationTemplateEngine templateEngine,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _templateEngine = templateEngine;
        }

        [HttpGet]
        [Transactional]
        public ActionResult BatchDocument(SystemNotification systemNotification, int id)
        {
            return View(new BatchViewModel(Repository, _templateEngine, systemNotification, id));
        }
    }
}