<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.Agency.ViewModels.PropertyManagerViewModel>" %>
<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-property-manager-form")%>
	
<% using (var form = Html.BeginForm("Edit", "PropertyManager", new { id = Model.PropertyManager.Id, agencyId = Model.Agency.Id }, FormMethod.Post, new { id = "edit-property-manager-form" }))
	{ %>           
		<%= Html.AntiForgeryToken() %>
		<%= Html.HiddenFor(model => model.PropertyManager.RowVersion)%>
		<% if (TempData["IsValid"]!=null)
		   {
			   Response.Write(Html.Hidden("IsValid", true));
			   TempData.Remove("IsValid");
		   }
		%>
		<div class="clear"></div>
		<h3><%=Html.GetCreateEditText(Model.PropertyManager.Id) + " Property Manager" %></h3>
		<div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
			<div class="left">       
				<div class="row">
					<%= Html.LabelFor(model => model.PropertyManager.Name)%>
					<%= Html.TextBoxFor(model => model.PropertyManager.Name, new { maxlength = 100, @class = "textbox" })%>
					<%= Html.RequiredFieldIndicator() %>
				</div>    
				<div class="row">
					<%= Html.LabelFor(model => model.PropertyManager.Position)%>
					<%= Html.TextBoxFor(model => model.PropertyManager.Position, new { maxlength = 50, @class = "textbox" })%>
				</div>            
				<div class="row">
					<%= Html.LabelFor(model => model.PropertyManager.Telephone)%>
					<%= Html.TextBoxFor(model => model.PropertyManager.Telephone, new { maxlength = 12, @class = "textbox" })%>
				</div>    
				<div class="row">
					<%= Html.LabelFor(model => model.PropertyManager.Email)%>
					<%= Html.TextBoxFor(model => model.PropertyManager.Email, new { maxlength = 400, @class = "textbox" })%>
				</div>
				<div class="row">
					<%= Html.LabelFor(model => Model.PropertyManager.IsFixedFeeService)%>
					<%= Html.CheckBoxFor(model => model.PropertyManager.IsFixedFeeService)%>
				</div>
				<%--<div class="row">
					<%= Html.LabelFor(model => Model.PropertyManager.UsePersonalisedEntryNotification)%>
					<%= Html.CheckBoxFor(model => model.PropertyManager.UsePersonalisedEntryNotification)%>
				</div>--%>
			</div>
		</div>
		<div class="buttons">
			<input type="button" name="ApplyButton" value="Save"   class="button ui-corner-all ui-state-default " onclick="javascript:savePropertyManager(<%=Model.PropertyManager.Id %>);return false;" />
			<input type="button" onclick="javascript:editPropertyManager(0);return false;" value="Cancel"  class="button ui-corner-all ui-state-default " />
		</div>
<% } %>
	
