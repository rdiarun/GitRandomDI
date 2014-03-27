using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using DetectorInspector.Model;

namespace DetectorInspector.ViewModels
{
    public class PageHelpViewModel : ViewModel
    {
        public PageHelpViewModel(Help help, string helpCode)
        {
            Help = help;
            Help.Code = helpCode;
        }

        public Help Help { get; set; }
        
    }
}