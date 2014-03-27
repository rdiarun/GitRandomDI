using System;
using System.ComponentModel;
using System.IO;
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
using System.Collections.Generic;
using System.Security.Principal;
using System.Data;
using System.Text;

namespace DetectorInspector.Areas.PropertyInfo.Controllers
{
    [HandleError]
    [RequirePermission(Permission.AdministerSystem)]
    public class EmailController : SiteController
    {
        private IPropertyRepository _propertyRepository;

        public EmailController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IPropertyRepository propertyRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _propertyRepository = propertyRepository;    
        }

    }
}