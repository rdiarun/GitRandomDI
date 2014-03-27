using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DetectorInspector.Areas.Agency.ViewModels;
using DetectorInspector.Controllers;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using Kiandra.Data;
using Kiandra.Web.Mvc;
using System.IO;

namespace DetectorInspector.Areas.Agency.ViewModels
{
    public class AgencyUserViewModel : ViewModel
    {
        //protected IRepository Repository { get; private set; }
        //private readonly IAgencyRepository _agencyRepository;
        public  AgencyUserViewModel()
        {
              
        }

        //[HttpPost]
        //[Transactional]
      //  public ActionResult GetItems(string sortBy, string sortDirection, int pageNumber, int pageSize)
      //  {
      //      int itemCount;
      //      int pageCount;
      //      var listSortDirection =
      //string.CompareOrdinal(sortDirection, "asc") == 0 ? ListSortDirection.Ascending : ListSortDirection.Descending;
      //      var items = Repository.GetActive<DetectorInspector.Model.Agency>(pageNumber, pageSize, sortBy, listSortDirection, out itemCount, out pageCount);
      //      var result = new
      //      {
      //          pageCount = pageCount,
      //          pageNumber = pageNumber,
      //          itemCount = itemCount,
      //          items = (
      //              from item in items
      //              select new
      //              {
      //                  id = item.Id.ToString(),
      //                  rowVersion = Convert.ToBase64String(item.RowVersion),
      //                  name = HttpUtility.HtmlEncode(item.Name),
      //                  agencyGroup = HttpUtility.HtmlEncode(item.AgencyGroup.Name),
      //                  activeCount = item.ActiveProperties.Count(p => p.IsCancelled.Equals(false)),
      //                  propertyCount = item.ActiveProperties.Count(),
      //                  privateCount = item.ActivePrivateLandlordProperties.Count(),
      //                  isCancelled = StringFormatter.BooleanToYesNo(item.IsCancelled),
      //                  isDeleted = StringFormatter.BooleanToYesNo(item.IsDeleted)
      //              }).ToArray()
      //      };

      //      return Json(result);
      //  }

    }
}