using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Text;
using Kiandra.Web.Mvc;

namespace DetectorInspector.Infrastructure
{
	public static class CheckBoxListHelpers
	{
		public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<CheckBoxListItem> checkBoxList)
		{
			return CheckBoxListCore(helper, name, checkBoxList, null);
		}

		public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<CheckBoxListItem> checkBoxList, object htmlAttributes)
		{
			var attributeDictionary = AnonymousTypeToDictionaryConverter.Convert(htmlAttributes);

			return CheckBoxListCore(helper, name, checkBoxList, attributeDictionary);
		}

		public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<CheckBoxListItem> checkBoxList, IEnumerable<string> selectedValues, object htmlAttributes)
		{
			var attributeDictionary = AnonymousTypeToDictionaryConverter.Convert(htmlAttributes);

			foreach (var item in checkBoxList)
			{
				item.Checked = selectedValues.Contains(item.Value);
			}

			return CheckBoxListCore(helper, name, checkBoxList, attributeDictionary);
		}

		public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, IEnumerable<string> selectedValues)
		{
			return CheckBoxListCore(helper, name, items, selectedValues, null);
		}

		public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, IEnumerable<string> selectedValues, object htmlAttributes)
		{
			var attributeDictionary = AnonymousTypeToDictionaryConverter.Convert(htmlAttributes);

			return CheckBoxListCore(helper, name, items, selectedValues, attributeDictionary);
		}

		public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, IEnumerable<string> selectedValues, IDictionary<string, object> htmlAttributes)
		{
			return CheckBoxListCore(helper, name, items, selectedValues, htmlAttributes);
		}

		private static string CheckBoxListCore(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, IEnumerable<string> selectedValues, IDictionary<string, object> htmlAttributes)
		{
			var checkBoxList = from i in items
								  select new CheckBoxListItem
								  {
									  Text = i.Value,
									  Value = i.Key,
									  Checked = (selectedValues != null && selectedValues.Contains(i.Key))
								  };

			return CheckBoxListCore(helper, name, checkBoxList, htmlAttributes);
		}

		private static string CheckBoxListCore(this HtmlHelper helper, string name, IEnumerable<CheckBoxListItem> checkBoxList, IDictionary<string, object> htmlAttributes)
		{
			var output = new StringBuilder();

			var containerTag = new TagBuilder("span");
			
			containerTag.MergeAttributes(htmlAttributes);

			output.Append(containerTag.ToString(TagRenderMode.StartTag));

			foreach (var item in checkBoxList)
			{
				var itemContainerTag = new TagBuilder("span");

				output.Append(itemContainerTag.ToString(TagRenderMode.StartTag));

				var inputTag = new TagBuilder("input");

				var id = string.Format("{0}_{1}", name, item.Value);

				inputTag.MergeAttribute("type", "checkbox");
				inputTag.MergeAttribute("id", id);
				inputTag.MergeAttribute("name", name);
				inputTag.MergeAttribute("value", item.Value);

				if (item.Checked)
				{
					inputTag.MergeAttribute("checked", "true");
				}

				output.Append(inputTag.ToString(TagRenderMode.SelfClosing));

				var labelTag = new TagBuilder("label");

				labelTag.MergeAttribute("for", id);

                id = string.Format("extra_{0}_{1}", name, item.Value);
                var extraSpanTag = new TagBuilder("span");
                extraSpanTag.MergeAttribute("id", id);


				output.Append(labelTag.ToString(TagRenderMode.StartTag));
                output.Append(item.Text);
                output.Append(extraSpanTag.ToString(TagRenderMode.Normal));
                output.Append(labelTag.ToString(TagRenderMode.EndTag));
				output.Append(itemContainerTag.ToString(TagRenderMode.EndTag));
			}

			output.Append(containerTag.ToString(TagRenderMode.EndTag));

			return output.ToString();
		}
	}
}
