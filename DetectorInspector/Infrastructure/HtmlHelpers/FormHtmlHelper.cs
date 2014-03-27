using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Kiandra.Web.Mvc.UI;
using System.Web.Mvc;
using System.Web.Mvc.Html;
using System.Text;
using System.Collections;
using System.Linq.Expressions;
using System.Web.Routing;

namespace DetectorInspector.Infrastructure
{
    public static class FormHtmlHelper
    {
        public static string GetCreateEditText<TKey>(this HtmlHelper html)
        {
            if (EntityHtmlHelpers.IsCreate<TKey>(html))
            {
                return "Create";
            }
            else
            {
                return "Edit";
            }
        }

        public static string GetCreateEditText(this HtmlHelper html, Guid? id)
        {
            if (IsEdit(html, id))
            {
                return "Edit";
            }
            else
            {
                return "Create";
            }
        }

        public static string GetCreateEditText(this HtmlHelper html, int? id)
        {
            if (IsEdit(html, id))
            {
                return "Edit";
            }
            else
            {
                return "Create";
            }
        }

        public static bool IsEdit(this HtmlHelper html, Guid? id)
        {
            return (id.HasValue && id.Value != Guid.Empty);
        }

        public static bool IsEdit(this HtmlHelper html, int? id)
        {
            return (id.HasValue && id.Value > 0);
        }

        public static string EnumToRadioButtonList(this HtmlHelper html, object items, string radioButtonName)
        {
            StringBuilder stringBuilder = new StringBuilder();

            stringBuilder.AppendLine(@"<span class=""radioButtonList"">");

            foreach (KeyValuePair<string, string> keyValue in (IEnumerable)items)
            {
                stringBuilder.Append(html.RadioButton(radioButtonName, keyValue.Key, new { id = (radioButtonName + "_" + keyValue.Key) }));
                stringBuilder.Append(@"<label for=""");
                stringBuilder.Append(radioButtonName + "_" + keyValue.Key);
                stringBuilder.Append(@""">");
                stringBuilder.Append(keyValue.Value);
                stringBuilder.AppendLine(@"</label>");
            }

            //append hidden input to assist with binding validation
            stringBuilder.AppendLine(string.Format(@"<input type=""hidden"" id=""{0}"" name=""{0}"" />", radioButtonName));

            stringBuilder.AppendLine(@"</span>");

            return stringBuilder.ToString();
        }

        public static string GetYesNoRadioButtonList(this HtmlHelper html, string radioButtonName)
        {
            var yesNo = new List<KeyValuePair<string, string>>(2);

            yesNo.Add(new KeyValuePair<string, string>("true", "Yes"));
            yesNo.Add(new KeyValuePair<string, string>("false", "No"));

            return EnumToRadioButtonList(html, yesNo, radioButtonName);
        }

        public static string GetCheckBox(this HtmlHelper html, string checkboxId, string checkboxName, string checkboxValue, string[] selectedValues)
        {
            return GetCheckBox<string>(html, checkboxId, checkboxName, checkboxValue, selectedValues);
        }

        public static string GetCheckBox<T>(this HtmlHelper html, string checkboxId, string checkboxName, T checkboxValue, T[] selectedValues)
        {
            string isChecked = "";

            //decide if checked
            if (selectedValues != null && selectedValues.Contains(checkboxValue))
            {
                isChecked = "checked";
            }

            return string.Format(@"<input id=""{0}"" name=""{1}"" type=""checkbox"" value=""{2}""  {3} />", checkboxId, checkboxName, checkboxValue, isChecked);
        }

        public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items)
        {
            return CheckBoxList(helper, name, items, null, null);
        }

        public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, IDictionary<string, object> checkboxHtmlAttributes)
        {
            return CheckBoxList(helper, name, items, null, checkboxHtmlAttributes);
        }

        public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, IEnumerable<string> selectedValues)
        {
            return CheckBoxList(helper, name, items, selectedValues, null);
        }

        public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<KeyValuePair<string, string>> items, IEnumerable<string> selectedValues, IDictionary<string, object> checkboxHtmlAttributes)
        {
            var selectListItems = from i in items
                                  select new SelectListItem
                                  {
                                      Text = i.Value,
                                      Value = i.Key,
                                      Selected = (selectedValues != null && selectedValues.Contains(i.Key))
                                  };

            return CheckBoxList(helper, name, selectListItems, checkboxHtmlAttributes);
        }

        public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<SelectListItem> items)
        {
            return CheckBoxList(helper, name, items, null);
        }

        public static string CheckBoxList(this HtmlHelper helper, string name, IEnumerable<SelectListItem> items, IDictionary<string, object> checkboxHtmlAttributes)
        {
            var output = new StringBuilder();

            output.Append(@"<span class=""checkboxList"">");

            foreach (var item in items)
            {
                var checkboxList = new TagBuilder("input");

                checkboxList.MergeAttribute("type", "checkbox");
                checkboxList.MergeAttribute("name", name);
                checkboxList.MergeAttribute("value", item.Value);
                checkboxList.MergeAttribute("class", "checkBox");
                checkboxList.MergeAttribute("id", string.Format(@"{0}_{1}", name, item.Value));

                // Check to see if it's checked
                if (item.Selected)
                {
                    checkboxList.MergeAttribute("checked", "checked");
                }

                // Add any attributes
                if (checkboxHtmlAttributes != null)
                {
                    checkboxList.MergeAttributes(checkboxHtmlAttributes);
                }


                checkboxList.SetInnerText(item.Text);

                output.Append(checkboxList.ToString(TagRenderMode.SelfClosing));
                output.Append(@"<label for=""");
                output.Append(string.Format(@"{0}_{1}", name, item.Value));
                output.Append(@""">");
                output.Append(item.Text);
                output.Append("</label>");
            }

            output.Append("</span>");

            return output.ToString();
        }

        public static string LabelForKiandra<TModel, TValue>(this HtmlHelper<TModel> html, Expression<Func<TModel, TValue>> expression)
        {
            return LabelForKiandra(html, ":", expression);
        }

        public static string LabelForKiandra<TModel, TValue>(this HtmlHelper<TModel> html, string appendHtml, Expression<Func<TModel, TValue>> expression)
        {
            string label = html.LabelFor<TModel, TValue>(expression).ToString();

            label = label.Replace("</label>", appendHtml + "</label>");

            return label;
        }

        public static string Image(this HtmlHelper helper, string id, string url, string alternateText, string title, object htmlAttributes)  
        {  
            // Instantiate a UrlHelper   
            var urlHelper = new UrlHelper(helper.ViewContext.RequestContext);  
  
             // Create tag builder  
            var builder = new TagBuilder("img");  
              
            // Create valid id  
            builder.GenerateId(id);  
  
            // Add attributes  
            builder.MergeAttribute("src", urlHelper.Content(url));  
            builder.MergeAttribute("alt", alternateText);
            builder.MergeAttribute("title", title);  
            builder.MergeAttributes(new RouteValueDictionary(htmlAttributes));  
  
            // Render tag  
            return builder.ToString(TagRenderMode.SelfClosing);  
        }  
  
    }
}
