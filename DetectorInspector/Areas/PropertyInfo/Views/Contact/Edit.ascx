<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.PropertyInfo.ViewModels.ContactEntryViewModel>" %>
<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-tenant-contact-form")%>
	
<% using (var form = Html.BeginForm("Edit", "Contact", new { id = Model.ContactEntry.Id, propertyInfoId = Model.PropertyInfo.Id }, FormMethod.Post, new { id = "edit-tenant-contact-form" }))
    { %>           
        <%= Html.AntiForgeryToken() %>
        <%= Html.HiddenFor(model => model.ContactEntry.RowVersion)%>
        <% if (TempData["IsValid"]!=null)
           {
               Response.Write(Html.Hidden("IsValid", true));
               TempData.Remove("IsValid");
           }
        %>
        <div class="clear"></div>
        <h3><%=Html.GetCreateEditText(Model.ContactEntry.Id) + " Contact Entry"%></h3>
        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
            <div class="left">       
                <div class="row">
                    <label for="TenantContact_ContactNumber" class="narrow">Contact Number</label>
                    <%= Html.TextBoxFor(model => model.ContactEntry.ContactNumber, new { maxlength = 12, @class = "textbox narrow" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>    
                <div class="row">
	                <label for="ContactEntry_ContactNumberType_Id" class="narrow">Contact Number Type</label>
	                <%= Html.DropDownList("ContactEntry.ContactNumberType.Id", Model.ContactNumberTypes, "-- Please Select --", new { @class = "narrow" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>            
            </div>
        </div>
        <div class="buttons">
            <input type="button" name="ApplyButton" value="Save"   class="button ui-corner-all ui-state-default " onclick="javascript:saveTenantContact(<%=Model.ContactEntry.Id %>);return false;" />
            <input type="button" onclick="javascript:editTenantContact(0);return false;" value="Cancel"  class="button ui-corner-all ui-state-default " />
        </div>
<% } %>
    
