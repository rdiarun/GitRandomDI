using System;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Kiandra.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using Kiandra.Data;

namespace DetectorInspector.Controllers
{
    [RequirePermission(Permission.AdministerSystem)]
	public class AuditController : SiteController
	{
		private IAuditRepository _repository;
		private IModelMetadataProvider _modelMetadataProvider;

		public AuditController(
                                ITransactionFactory transactionFactory,
                                IAuditRepository auditRepository, 
                                IModelMetadataProvider modelMetadataProvider,
                                IRepository repository,
                                IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
		{
            _repository = auditRepository;
			_modelMetadataProvider = modelMetadataProvider;
		}

		[HttpPost]
		[Transactional]
		public ActionResult GetAuditEntries(string sortBy, string sortDirection, int pageNumber, int pageSize, string entityType, string entityKey)
		{
			int itemCount;
			int pageCount;

			var listSortDirection =
				string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

			var items = _repository.GetOverviewForEntity(entityType, entityKey, pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

			var result = new
			{
				pageCount = pageCount,
				pageNumber = pageNumber,
				itemCount = itemCount,
				items = (
					from item in items
					select new
					{
						id = item.Id, 
						action = HttpUtility.HtmlEncode(item.Description),
                        user = HttpUtility.HtmlEncode(item.UserName),
                        createdUtcDate = StringFormatter.UtcToLocalDateTime(item.CreatedUtcDate)
					}).ToArray()
			};

			return Json(result);
		}

		[HttpPost]
		[Transactional]
		public ActionResult GetAuditEntryActions(int id)
		{
			var items = _repository.GetAuditDetails(id);

			var result = new
			{
				rows = (
					from item in items
					select new
					{
						cell = new string[]
						{
							HttpUtility.HtmlEncode(item.Action.ToString()),
							HttpUtility.HtmlEncode(_modelMetadataProvider.GetModelDisplayName(item.EntityType)),
							HttpUtility.HtmlEncode(item.EntityKey),
							HttpUtility.HtmlEncode(_modelMetadataProvider.GetModelPropertyDisplayName(item.EntityType, item.PropertyName)),
							HttpUtility.HtmlEncode(item.CurrentValue)
						}
					}).ToArray()
			};

			return Json(result);
		}

		[HttpPost]
		[Transactional]
		public ActionResult GetJobAuditEntries(int jobId, string sortBy, string sortDirection, int pageNumber, int pageSize)
		{
			int itemCount;
			int pageCount;

			var listSortDirection =
				string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

			var items = _repository.GetOverviewForJobEntity(jobId, pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

			var result = new
			{
				pageCount = pageCount,
				pageNumber = pageNumber,
				itemCount = itemCount,
				items = (
					from item in items
					select new
					{
						id = item.Id,
						action = HttpUtility.HtmlEncode(item.Description),
						user = HttpUtility.HtmlEncode(item.UserName),
						createdUtcDate = StringFormatter.UtcToLocalDateTime(item.CreatedUtcDate)
					}).ToArray()
			};

			return Json(result);
		}

		[HttpPost]
		[Transactional]
		public ActionResult GetContactAuditEntries(int contactId, string sortBy, string sortDirection, int pageNumber, int pageSize)
		{
			int itemCount;
			int pageCount;

			var listSortDirection =
				string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;

			var items = _repository.GetOverviewForContactEntity(contactId, pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);

			var result = new
			{
				pageCount = pageCount,
				pageNumber = pageNumber,
				itemCount = itemCount,
				items = (
					from item in items
					select new
					{
						id = item.Id,
						action = HttpUtility.HtmlEncode(item.Description),
						user = HttpUtility.HtmlEncode(item.UserName),
						createdUtcDate = StringFormatter.UtcToLocalDateTime(item.CreatedUtcDate)
					}).ToArray()
			};

			return Json(result);
		}

		[HttpPost]
		[Transactional]
		public ActionResult GetContactAuditEntryActions(int id)
		{
			var items = _repository.GetAuditDetails(id);

			var result = new
			{
				rows = (
					from item in items
					select new
					{
						cell = new string[]
						{
							HttpUtility.HtmlEncode(item.Action.ToString()),
							HttpUtility.HtmlEncode(_modelMetadataProvider.GetModelDisplayName(item.EntityType)),
							HttpUtility.HtmlEncode(item.EntityKey),
							HttpUtility.HtmlEncode(_modelMetadataProvider.GetModelPropertyDisplayName(item.EntityType, item.PropertyName)),
							HttpUtility.HtmlEncode(item.PreviousValue),
							HttpUtility.HtmlEncode(item.CurrentValue)
						}
					}).ToArray()
			};

			return Json(result);
		}
	}
}
