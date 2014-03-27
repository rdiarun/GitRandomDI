<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
	Page.Title = Html.GetCreateEditText(Model.PropertyInfo.Id) + " Property: " + Model.PropertyInfo.ToString();
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
	<h2><%=Page.Title %></h2>
	
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
	
	<% using (var form = Html.BeginForm("Landlord", "Home", FormMethod.Post, new { id = "edit-form" }))
	   { %>           
			<%= Html.AntiForgeryToken() %>
			<%= Html.HiddenFor(model => model.PropertyInfo.RowVersion)%>
			<%= Html.Hidden("PropertyInfo.State.Id", Model.PropertyInfo.State != null ? Model.PropertyInfo.State.Id.ToString() : string.Empty)%>
			<%= Html.Hidden("PropertyInfo.PostalState.Id", Model.PropertyInfo.PostalState != null ? Model.PropertyInfo.PostalState.Id.ToString() : string.Empty)%>
			<%= Html.Hidden("PropertyInfo.Agency.Id", Model.PropertyInfo.Agency != null ? Model.PropertyInfo.Agency.Id.ToString() : string.Empty)%>
			<%= Html.Hidden("PropertyInfo.PropertyManager.Id", Model.PropertyInfo.PropertyManager != null ? Model.PropertyInfo.PropertyManager.Id.ToString() : string.Empty)%>
			<%= Html.Hidden("PropertyInfo.Zone.Id", Model.PropertyInfo.Zone != null ? Model.PropertyInfo.Zone.Id.ToString() : string.Empty)%>

			<%= Html.Hidden("PropertyInfo.PrivateLandlordAgency.Id", Model.PropertyInfo.PrivateLandlordAgency != null ? Model.PropertyInfo.PrivateLandlordAgency.Id.ToString() : string.Empty)%>
			<%= Html.Hidden("PropertyInfo.PrivateLandlordPropertyManager.Id", Model.PropertyInfo.PrivateLandlordPropertyManager != null ? Model.PropertyInfo.PrivateLandlordPropertyManager.Id.ToString() : string.Empty)%>


			<div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
				<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
					<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Details", "View", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
					<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Contact Details", "Index", "Contact", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
					<% if (!Model.IsCreate())
					   { %>          
				   
					<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Bookings & Service History", "ServiceSheet", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
					
					<%} %>
					<li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Landlord Details</a></li>
					<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Change Log", "Index", "ChangeLog", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>

				</ul>
			
				<div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
					<div class="left">
						<div class="row">
							<%= Html.LabelFor(model => model.PropertyInfo.LandlordName)%>
							<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordName, new { maxlength = 100, @class = "textbox" })%>
							<% if (Model.PropertyInfo.JobType != 1) { Response.Write(Html.RequiredFieldIndicator()); }%>
						</div>    
						<div class="row">
							<%= Html.LabelFor(model => model.PropertyInfo.LandlordEmail)%>
							<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordEmail, new { maxlength = 400, @class = "textbox" })%>
							<% if (Model.PropertyInfo.JobType != 1) { %><span class="required landlordReqired">+</span> <% }%>
						</div> 
						<div class="row">
							<%= Html.LabelFor(model => model.PropertyInfo.LandlordTelephone)%>
							<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordTelephone, new { maxlength = 50, @class = "textbox" })%>
							<% if (Model.PropertyInfo.JobType != 1) { %><span class="required landlordReqired">+</span> <% }%>
						</div>
					</div>
					<div class="right">
						 <div class="row">
							<%= Html.LabelFor(model => model.PropertyInfo.LandlordAddress)%>
							<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordAddress, new { @class = "textbox" })%>
							<% if (Model.PropertyInfo.JobType != 1) { Response.Write(Html.RequiredFieldIndicator()); }%>
						</div>    
						<div class="row">
							<%= Html.LabelFor(model => model.PropertyInfo.LandlordSuburb)%>
							<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordSuburb, new { maxlength = 50, @class = "textbox" })%>
							<% if (Model.PropertyInfo.JobType != 1) { Response.Write(Html.RequiredFieldIndicator()); }%>
						</div>    
						<div class="row">
							<label for="PropertyInfo_LandlordState_Id">Landlord State</label>
							<%= Html.DropDownList("PropertyInfo.LandlordState.Id", Model.LandlordStates, "-- Please Select --")%>
							<% if (Model.PropertyInfo.JobType != 1) { Response.Write(Html.RequiredFieldIndicator()); }%>
						</div>            
						<div class="row">
							<%= Html.LabelFor(model => model.PropertyInfo.LandlordPostCode)%>
							<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordPostCode, new { maxlength = 4, @class = "textbox small" })%>
							<% if (Model.PropertyInfo.JobType != 1) { Response.Write(Html.RequiredFieldIndicator()); }%>
						</div>   
						<div class="row">
							<%= Html.LabelFor(model => model.PropertyInfo.LandlordCountry)%>
							<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordCountry, new { maxlength = 50, @class = "textbox" })%>
							<% if (Model.PropertyInfo.JobType != 1) { Response.Write(Html.RequiredFieldIndicator()); }%>
						</div>    
	
					</div>
				</div>
				<div class="clear"></div>
				<div class="buttons">
					<input type="submit" name="ApplyButton" value="Save" onclick="javascript:return(landLordValidate());" class="button ui-corner-all ui-state-default " />
					<input type="submit" name="SaveButton" value="Save &amp; Close" onclick="javascript:return(landLordValidate());" class="button ui-corner-all ui-state-default " />
					<input type="button" name="CancelButton" value="Cancel" onclick="javascript:openPropertyInfo(<%=Model.PropertyInfo.Id %>);" class="button ui-corner-all ui-state-default " />
				</div>
		   </div>
	<% } %>


<script type="text/javascript">
	$().ready(function () {
		initAddressAutoComplete('<%= Url.Action("GetSuburbs", "Suburb", new { area = "Admin" }) %>', '#PropertyInfo_LandlordState_Id', '#PropertyInfo_LandlordSuburb', '#PropertyInfo_LandlordPostCode');

	});
	 

	function landLordValidate()
	{
		if ("<%=Model.PropertyInfo.JobType %>"  !="<%= (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged.GetHashCode())  %>" )
		{

			if ( $("#PropertyInfo_LandlordName").val()=="")
			{
				alert("You need to enter the Landlord Name");
				return false;
			}
			if ($("#PropertyInfo_LandlordAddress").val()=="")
			{
				alert("You need to enter the Landlord Address");
				return false;
			}
			if ($("#PropertyInfo_LandlordSuburb").val()=="")
			{
				alert("You need to enter the Landlord Suburb");
				return false;
			}
			if ( $("#PropertyInfo_LandlordPostCode").val()=="")
			{
				alert("You need to enter the Landlord Postcode");
				return false;
			}
			if ($("#PropertyInfo_LandlordCountry").val()=="" )
			{
				alert("You need to enter the Landlord Country");
				return false;
			}
			if ($("#PropertyInfo_LandlordState.Id").val()=="")
			{
				alert("You need to enter the Landlord State");
				return false;
			}

			if ($("#PropertyInfo_LandlordEmail").val()=="" &&  $("#PropertyInfo_LandlordTelephone").val()=="")
			{
				alert("You need to enter the Landlord Email or Telephone number");
				return false;
			}

			return true;

		}
		return true;
	}
	   
	</script>
</asp:Content>


