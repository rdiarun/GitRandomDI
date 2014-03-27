using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Text;
using Kiandra.Web.Mvc;

namespace DetectorInspector.Infrastructure
{
	public static class RadioButtonListHelpers
	{
		public static string RadioButtonList(this HtmlHelper helper, string name, IEnumerable<RadioButtonListItem> checkBoxList, string selectedValue, object htmlAttributes)
		{
			var attributeDictionary = AnonymousTypeToDictionaryConverter.Convert(htmlAttributes);

			return RadioButtonListCore(helper, name, checkBoxList, selectedValue, attributeDictionary);
		}

		public static string RadioButtonList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, string selectedValue)
		{
			return RadioButtonListCore(helper, name, items, selectedValue, null);
		}

		public static string RadioButtonList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, string selectedValue, object htmlAttributes)
		{
			var attributeDictionary = AnonymousTypeToDictionaryConverter.Convert(htmlAttributes);

			return RadioButtonListCore(helper, name, items, selectedValue, attributeDictionary);
		}

		public static string RadioButtonList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, string selectedValue, IDictionary<string, object> htmlAttributes)
		{
			return RadioButtonListCore(helper, name, items, selectedValue, htmlAttributes);
		}

		private static string RadioButtonListCore(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, string selectedValue, IDictionary<string, object> htmlAttributes)
		{
			var radioList = from i in items
								  select new RadioButtonListItem
								  {
									  Text = i.Value.ToString(),
									  Value = i.Key
								  };

			return RadioButtonListCore(helper, name, radioList, selectedValue, htmlAttributes);
		}

		private static string RadioButtonListCore(this HtmlHelper helper, string name, IEnumerable<RadioButtonListItem> checkBoxList, string selectedValue, IDictionary<string, object> htmlAttributes)
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

				var id = string.Format("{0}_{1}", name, HttpUtility.HtmlAttributeEncode(item.Value));

				inputTag.MergeAttribute("type", "radio");
				inputTag.MergeAttribute("id", id);
				inputTag.MergeAttribute("name", name);
				inputTag.MergeAttribute("value", item.Value);

				if (string.CompareOrdinal(item.Value, selectedValue) == 0)
				{
					inputTag.MergeAttribute("checked", "true");
				}

				output.Append(inputTag.ToString(TagRenderMode.SelfClosing));

				var labelTag = new TagBuilder("label");

				labelTag.MergeAttribute("for", id);
				labelTag.SetInnerText(item.Text);

				output.Append(labelTag.ToString(TagRenderMode.Normal));
				output.Append(itemContainerTag.ToString(TagRenderMode.EndTag));
			}

			output.Append(containerTag.ToString(TagRenderMode.EndTag));

			return output.ToString();
		}
	}
}
