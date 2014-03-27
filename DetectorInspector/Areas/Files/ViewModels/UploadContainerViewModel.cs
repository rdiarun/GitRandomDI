using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DetectorInspector.Model;
using DetectorInspector.Data;
using System.Web.Mvc;
using System.Security.Principal;
using DetectorInspector.Infrastructure;
using DetectorInspector.ViewModels;

namespace DetectorInspector.Areas.Files.ViewModels
{
    public class UploadContainerViewModel : ViewModel
    {		
        public UploadContainerViewModel(UploadContainer uploadContainer)
        {
            UploadContainer = uploadContainer;
        }

        public UploadContainer UploadContainer { get; private set; }
    }
}
