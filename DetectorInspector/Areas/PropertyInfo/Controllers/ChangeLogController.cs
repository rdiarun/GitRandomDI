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
using DetectorInspector.Areas.PropertyInfo.ViewModels;
using System.IO;

namespace DetectorInspector.Areas.PropertyInfo.Controllers
{
    [HandleError]
 //   [RequirePermission(Permission.AdministerSystem)]
    public class ChangeLogController : SiteController
    {
        IPropertyRepository _propertyRepository;
        IAgencyRepository _agencyRepository;
        IChangeLogRepository _changeLogRepository;


        public ChangeLogController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IPropertyRepository propertyRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository,
            IAgencyRepository agencyRepository,
            IChangeLogRepository changeLogRepository
            )
            : base(transactionFactory, repository, helpRepository)
        {
            _propertyRepository = propertyRepository;
            _agencyRepository = agencyRepository;
            _changeLogRepository = changeLogRepository;
        }

        [HttpGet]
        public ActionResult Index(int id)
        {

            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, true, _agencyRepository);

            return View(model);
        }



        [HttpPost]
        [Transactional]
        public ActionResult GetItems(int propertyInfoId, string sortBy, string sortDirection, int pageNumber, int pageSize)
        {


            var model = _propertyRepository.Get(propertyInfoId);


            int itemCount;
            int pageCount;

            var listSortDirection =
                string.CompareOrdinal(sortDirection, "desc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

            var items = model.LogItems.GetPage(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

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
                        dateTime = item.CreatedUtcDate.ToLocalTime().ToShortDateString() + " " + item.CreatedUtcDate.ToLocalTime().ToShortTimeString(),
                        itemType = item.ItemType.GetDescription(),
                        userName = item.CreatedByUserName
                    }).ToArray()
            };

            var jsonData = Json(result);
            return jsonData;
        }

        [HttpPost]
        [Transactional]
        public ActionResult GetDetails(int id)
        {
            var logEntry = _changeLogRepository.Get(id);

            var result = new
            {
                itemData = logEntry.ToHTML()
            };
            var jsonData = Json(result);
            return jsonData;
        }



        [HttpGet]
        public FileStreamResult GetAttachment(int id)
        {

            ChangeLog cl = _changeLogRepository.Get(id);

            string savedFileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "LinkedDatabaseContent/LogItems");
            savedFileName = Path.Combine(savedFileName, cl.AttachmentUID);
            var f = new FileStream(savedFileName, FileMode.OpenOrCreate);
            
            return File(f, cl.AttachmentDocType, cl.AttachmentDocName);

        }



        [Authorize]
        [ChildActionOnly]
        [Transactional]
        public ActionResult Details(int id)
        {
            var model = new PropertyInfoViewModel(Repository, _propertyRepository, id, false, _agencyRepository);

            return PartialView(model);
        }

    }
}