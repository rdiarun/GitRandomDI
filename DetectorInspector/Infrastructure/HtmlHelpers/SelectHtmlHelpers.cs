using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DetectorInspector.Infrastructure
{
	public static class SelectHtmlHelpers
    {
	
        public static SelectListItem[] GetYesNoSelectListItems()
        {
            var yesItem = new SelectListItem()
			{
				Value = Boolean.TrueString,
				Text = "Yes"
			};

			var noItem = new SelectListItem()
			{
				Value = Boolean.FalseString,
				Text = "No"
			};

			return new SelectListItem [] { yesItem, noItem };
        }

        public static SelectListItem[] GetTimeSelectListItems(this HtmlHelper html)
        {
            return GetTimeSelectListItems(html, null);
        }

        public static SelectListItem[] GetTimeSelectListItems(this HtmlHelper html, DateTime? selectedOption)
        {
            var list = new List<SelectListItem>();
            for (var i = 12; i <= 40; i++)
            {
                list.Add(new SelectListItem()
                {
                    Text = DateTime.Today.AddMinutes(i * 30).ToString("hh:mm tt"),
                    Value = DateTime.Today.AddMinutes(i * 30).ToString("hh:mm tt"),
                    Selected = selectedOption.HasValue?(selectedOption.Value.TimeOfDay.Equals(DateTime.Today.AddMinutes(i*30).TimeOfDay)?true:false):false
                });
            }
            list.Insert(0, new SelectListItem() { Text = string.Empty, Value = string.Empty });
            return list.ToArray();
        }

        public static SelectListItem[] GetYesNoSelectListItems(this HtmlHelper html, bool selectedOption)
        {
            var yesItem = new SelectListItem()
			{
				Value = Boolean.TrueString,
				Text = "Yes",
                Selected = selectedOption
			};

			var noItem = new SelectListItem()
			{
				Value = Boolean.FalseString,
				Text = "No",
                Selected = !selectedOption
			};

			return new SelectListItem [] { yesItem, noItem };
        }
		public static SelectListItem[] GetYesNoSelectListItems(this HtmlHelper html)
		{
            return GetYesNoSelectListItems(html, true);
		}
	}
}
