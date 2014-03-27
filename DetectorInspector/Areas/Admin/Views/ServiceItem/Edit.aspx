<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Admin.ViewModels.ServiceItemViewModel>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="InitContent" runat="server">
<% 
	Page.Title = Html.GetCreateEditText(Model.ServiceItem.Id) + " Service Item";
%>
</asp:Content>

<asp:Content ID="Content6" ContentPlaceHolderID="MainContent" runat="server">
	
	<h2><%= Page.Title %></h2>
	
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
	<% using (var form = Html.BeginForm("Edit", "ServiceItem", FormMethod.Post, new { id = "edit-form" } )) { %>
		
	<fieldset>
		<legend>Properties</legend>
	
		<%= Html.AntiForgeryToken() %>
		<%= Html.HiddenFor(model => model.ServiceItem.RowVersion)%>
		
		<div class="left">
			<div class="row">
				<%= Html.LabelFor(model => model.ServiceItem.Name)%>
				<%= Html.TextBoxFor(model => model.ServiceItem.Name, new { maxlength = 200, @class = "textbox" })%>
				<%= Html.RequiredFieldIndicator() %>
			</div>            
		
			<div class="row">
				<%= Html.LabelFor(model => model.ServiceItem.Code)%>
				<%= Html.TextBoxFor(model => model.ServiceItem.Code, new { maxlength = 50, @class = "textbox" })%>
				<%= Html.RequiredFieldIndicator() %>
			</div>            

			<div class="row">
				<%= Html.LabelFor(model => model.ServiceItem.QuickBooksCode)%>
				<%= Html.TextBoxFor(model => model.ServiceItem.QuickBooksCode, new { maxlength = 50, @class = "textbox" })%>
				<%= Html.RequiredFieldIndicator() %>
			</div>                    

			<div class="row">
				<%= Html.LabelFor(model => model.ServiceItem.QuickBooksDescription)%>
				<%= Html.TextAreaFor(model => model.ServiceItem.QuickBooksDescription, new { maxlength = 400, @class = "textarea medium" })%>
				<%= Html.RequiredFieldIndicator() %>
			</div>                    
 
						<div class="row">
				<%= Html.LabelFor(model => model.ServiceItem.QuickBooksFreeAndFixedFeeDescription)%>
				<%= Html.TextAreaFor(model => model.ServiceItem.QuickBooksFreeAndFixedFeeDescription, new { maxlength = 400, @class = "textarea medium" })%>
				<%= Html.RequiredFieldIndicator() %>
			</div>            
			<div class="row">
				<%= Html.LabelFor(model => model.ServiceItem.Price)%>
				<%= Html.TextBoxFor(model => model.ServiceItem.Price, new { maxlength = 10, @class = "textbox" })%>
				<%= Html.RequiredFieldIndicator() %>
			</div>            
		 
			<div class="buttons">
				<input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
				<input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
				<%= Html.ActionButton("Cancel", "Index", "ServiceItem", null, new { @class = "button ui-corner-all ui-state-default " })%>
			</div>
		
		</div> 
	</fieldset>
	<% } %>
	
	<div class="trail">
		<% Html.RenderPartial("AuditTrail", Model.ServiceItem); %> | 
	</div>
</asp:Content>