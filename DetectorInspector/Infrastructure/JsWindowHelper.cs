using System.Web.Mvc;

namespace DetectorInspector.Infrastructure
{
    public class JsWindowHelper
    {
        private const string _applyButtonName = "ApplyButton";

        public static bool IsWindowToClose(ControllerContext context)
        {
            bool result = true;
            if (context.HttpContext.Request.Form[_applyButtonName] != null)
            {
                result = false;                                                                 
            }
            return result;
        }
    }
}
