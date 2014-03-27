<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
	Page.Title = Html.GetCreateEditText(Model.PropertyInfo.Id) + " Property: " + Model.PropertyInfo.ToString();
	
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	<%= Html.IncludeScript("~/Content/Scripts/dirtyDataCheck.js") %>	
	<h2><%=Page.Title %></h2>
	
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
	
			<div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
				<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
					<li id="detailsTab" class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active" onclick="detailsTabClicked()"><a href="#details-tab.....">Details</a></li>
					<% if (!Model.IsCreate())
					   { %>          
					   <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Contact Details", "Index", "Contact", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
					   <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Bookings & Service History", "ServiceSheet", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
					   
					<%} %>
					<%-- 				   <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Landlord Details", "Landlord", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
 --%>
				   <li id="landlordTab" class="ui-state-default ui-corner-top" onclick="landlordTabClicked();"><a href="#">Landlord</a></li>

				</ul>
				<% using (Html.BeginForm("PerformBulkAction", "Home", FormMethod.Post, new { id = "bulk-form" }))
				   {%>
					<%= Html.Hidden("bulkAction")%>
					<%= Html.Hidden("notificationDate")%>
				<% } %>
				<% using (var form = Html.BeginForm("Edit", "Home", FormMethod.Post, new { id = "edit-form" }))
					{ %>           
						<%= Html.AntiForgeryToken() %>
						<%= Html.HiddenFor(model => model.PropertyInfo.RowVersion)%>
						<%= Html.Hidden("PropertyInfo.Zone.Id", Model.PropertyInfo.Zone != null ? Model.PropertyInfo.Zone.Id.ToString() : string.Empty)%>
						<%= Html.Hidden("PropertyInfo.PostalState.Id", Model.PropertyInfo.PostalState != null ? Model.PropertyInfo.PostalState.Id.ToString() : string.Empty)%>

						<%-- 
						<%= Html.Hidden("PropertyInfo.LandlordState.Id", Model.PropertyInfo.LandlordState != null ? Model.PropertyInfo.LandlordState.Id.ToString() : string.Empty)%>
						<%= Html.Hidden("PropertyInfo.LandlordName", Model.PropertyInfo.LandlordName ) 
						<%= Html.Hidden("PropertyInfo.LandlordEmail", Model.PropertyInfo.LandlordEmail )%>
						<%= Html.Hidden("PropertyInfo.LandlordTelephone", Model.PropertyInfo.LandlordTelephone )%>
						<%= Html.Hidden("PropertyInfo.LandlordAddress", Model.PropertyInfo.LandlordAddress )%>
						<%= Html.Hidden("PropertyInfo.LandlordSuburb", Model.PropertyInfo.LandlordSuburb )%>
						<%= Html.Hidden("PropertyInfo.LandlordPostCode", Model.PropertyInfo.LandlordPostCode )%>
						<%= Html.Hidden("PropertyInfo.LandlordCountry", Model.PropertyInfo.LandlordCountry )%>
				--%>

				<div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
					<div class="left">
						<fieldset class="narrow">
							<legend>Property Details</legend>
							<div class="row">
								<%=Html.LabelFor(model=>model.PropertyInfo.PropertyNumber) %>
								<span class="read-only"><%=Model.FormattedPropertyNumber%></span>
							
							</div>  
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.JobType)%>
								<%= Html.DropDownList("PropertyInfo.JobType", Model.JobTypes, "-- Please Select --", new { onchange = "jobTypeChanged()", @class="narrow" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>  

						   <div class="row" id="PropertyInfo_billTo" style="display:none;">
								<%= Html.LabelFor(model => model.PropertyInfo.PrivateLandlordBillTo)%>
								<%= Html.DropDownList("PropertyInfo.PrivateLandlordBillTo", Model.PrivateLandlordBillToTypes, "-- Please Select --", new {@class="narrow" })%>
							   <%= Html.RequiredFieldIndicator() %>
							</div>  
 
							<div class="row" id="PrivateLandlordAgencySelectRow" style="display:none;">
								<label for="PropertyInfo_PrivateLandlordAgency_Id">Agency</label>
								<%= Html.DropDownList("PropertyInfo.PrivateLandlordAgency.Id", Model.AgenciesNotPrivateLandlord, "-- Please Select --", new { onchange = "privateLandlordAgencyChanged()", @class="narrow" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>  
							<div class="row" id="PrivateLandlordPropertyManagerSelectRow" style="display:none;">
								<label for="PropertyInfo_PrivateLandlordPropertyManager_Id">Property Manager</label>
								<%= Html.DropDownList("PropertyInfo.PrivateLandlordPropertyManager.Id", Model.PrivateLandlordPropertyManagers, "-- Please Select --", new { @class="narrow"  })%>
							</div>  
							<div class="row" id="AgencySelectRow" style="display:none;">
								<label for="PropertyInfo_Agency_Id">Agency</label>
								<%= Html.DropDownList("PropertyInfo.Agency.Id", Model.AgenciesNotPrivateLandlord, "-- Please Select --", new { onchange = "agencyChanged()", @class="narrow" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>  
							<div class="row" id="PropertyManagerSelectRow" style="display:none;">
								<label for="PropertyInfo_PropertyManager_Id">Property Manager</label>
								<%= Html.DropDownList("PropertyInfo.PropertyManager.Id", Model.PropertyManagers, "-- Please Select --", new { @class="narrow"  })%>
							</div>  
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.UnitShopNumber)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.UnitShopNumber, new { maxlength = 50, @class = "textbox small" })%>
							</div>    
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.StreetNumber)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.StreetNumber, new { maxlength = 50, @class = "textbox small" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>    
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.StreetName)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.StreetName, new { @class = "textbox narrow" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>    
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.Suburb)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.Suburb, new { maxlength = 50, @class = "textbox narrow" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>    
							<div class="row">
								<label for="PropertyInfo_State_Id">State</label>
								<%= Html.DropDownList("PropertyInfo.State.Id", Model.States, "-- Please Select --", new { @class = "narrow" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>            
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.PostCode)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.PostCode, new { maxlength = 4, @class = "textbox small" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>   
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.KeyNumber)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.KeyNumber, new { maxlength = 50, @class = "textbox narrow" })%>
							</div>    
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.Notes)%>
								<%= Html.TextAreaFor(model => Model.PropertyInfo.Notes, new { @class = "narrow" })%>
							</div>
							<!---
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.Discount)%>
								<%= Html.Hidden("PropertyInfo.Discount", string.Format("{0:f2}", Model.PropertyInfo.Discount), new { @class = "small textbox money" })%>
								<span class="read-only"><%=string.Format("{0:f2}", Model.PropertyInfo.Discount)%></span>
							</div>
								--->
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.DiscountPercentage)%>
								<%= Html.TextBox("PropertyInfo.DiscountPercentage", string.Format("{0:f2}", Model.PropertyInfo.DiscountPercentage), new { @class = "small textbox money" })%>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.HasLargeLadder)%>
								<%= Html.CheckBoxFor(model => model.PropertyInfo.HasLargeLadder)%>
							</div>    
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.LastServicedDate)%>
								<%= Html.TextBox("PropertyInfo.LastServicedDate", StringFormatter.LocalDate(Model.PropertyInfo.LastServicedDate), new { @class = "datepicker" })%>
							</div>
													 <div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.IsFixedFeeService)%>
								<span class="read-only"><%= Html.CheckBoxFor(model => model.PropertyInfo.IsFixedFeeService)%></span>
							</div>

							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.IsFreeService)%>
							<span class="read-only"><%= Html.CheckBoxFor(model => model.PropertyInfo.IsFreeService)%></span>
																

						</fieldset>
						 <fieldset class="narrow" style="height: 151px;">
							<legend>Status Details</legend>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.InspectionStatus)%>
								<span class="read-only"><%=EnumHelper.GetDescription(Model.PropertyInfo.InspectionStatus)%></span>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.InspectionStatusUpdatedDate)%>
								<span class="read-only"><%=StringFormatter.UtcToLocalDateTime(Model.PropertyInfo.InspectionStatusUpdatedDate)%></span>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.ElectricalWorkStatus)%>
								<span class="read-only"><%=EnumHelper.GetDescription(Model.PropertyInfo.ElectricalWorkStatus)%></span>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.ElectricalWorkStatusUpdatedDate)%>
								<span class="read-only"><%=StringFormatter.UtcToLocalDateTime(Model.PropertyInfo.ElectricalWorkStatusUpdatedDate)%></span>
							</div>    
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.TenantLastUpdated)%>
								<span class="read-only"><%=StringFormatter.UtcToLocalDateTime(Model.PropertyInfo.TenantLastUpdated)%></span>
							</div>
	
						</fieldset>
					</div>
					<div class="right">
						<fieldset class="narrow" style="height: 100px;">
							<legend>Contact Details</legend>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.OccupantName)%>
								<%= Html.TextBoxFor(model => Model.PropertyInfo.OccupantName, new { @class = "textbox narrow" })%>
								<%= Html.RequiredFieldIndicator() %>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.ContactNotes)%>
								<%= Html.TextAreaFor(model => Model.PropertyInfo.ContactNotes, new { @class = "narrow" })%>
							</div>
						</fieldset>
						<fieldset class="narrow" style="height: 180px;">
							<legend>Miscellaneous</legend>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.SettlementDate)%>
								<%= Html.TextBox("PropertyInfo.SettlementDate", StringFormatter.LocalDate(Model.PropertyInfo.SettlementDate), new { @class = "datepicker" })%>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.PropertyHoldDate)%>
								<%= Html.TextBox("PropertyInfo.PropertyHoldDate", StringFormatter.LocalDate(Model.PropertyInfo.PropertyHoldDate), new { @class = "datepicker" })%>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.JobCode)%>
								<span class="read-only"><%=Model.PropertyInfo.JobCode%></span>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.HasSendNotification)%>
								<%= Html.CheckBoxFor(model => model.PropertyInfo.HasSendNotification)%>
							</div>             
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.IsOneOffService)%>
								<%= Html.CheckBoxFor(model => model.PropertyInfo.IsOneOffService)%>
							</div>     
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.IsServiceCompleted)%>
								<span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.IsServiceCompleted)%></span>                                
							</div>     
						</fieldset>
						<fieldset  class="narrow">
							<legend>Problem Details</legend>
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.HasProblem)%>
								<span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.HasProblem)%></span>
							</div>        
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.ProblemNotes)%>
								<span class="read-only" style="height: 58px; display: inline-block; overflow:auto;"><%=Model.PropertyInfo.ProblemNotes%></span>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.ProblemStatusUpdatedDate)%>
								<span class="read-only"><%=StringFormatter.LocalDateTime(Model.PropertyInfo.ProblemStatusUpdatedDate)%></span>
							</div>
						</fieldset>
						<fieldset class="narrow"  style="height: 220px;">
							<legend>Cancellation Details</legend>
							<div class="row">
								<span id="PropertyCancelledDisplay" style="font-weight:bold;"> <%   if (Model.PropertyInfo.IsCancelled == true) { Response.Write("Property is Cancelled"); } 
																									if (Model.PropertyInfo.IsReactivated == true) { Response.Write("Property has been Reactiavted"); }
																									if (Model.PropertyInfo.IsReactivated == false && Model.PropertyInfo.IsCancelled == false) { Response.Write("Property is Active"); } %></span>
								<%-- = Html.LabelFor(model => model.PropertyInfo.IsCancelled) --%>
								<%= Html.Hidden("PropertyInfo.IsCancelled", Model.PropertyInfo.IsCancelled)%>
								<%= Html.Hidden("PropertyInfo.IsReactivated", Model.PropertyInfo.IsReactivated)%>
							</div>        
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.CancellationNotes)%>
								<%= Html.TextAreaFor(model => Model.PropertyInfo.CancellationNotes, new { @class = "narrow" })%>
							</div>
							<div class="row">
								<%= Html.LabelFor(model => Model.PropertyInfo.CancellationDate)%>
								<span class="read-only"><%=StringFormatter.LocalDate(Model.PropertyInfo.CancellationDate)%></span>
							</div>
							
							<div class="row" >
								<%= Html.LabelFor(model => Model.PropertyInfo.ReactivationNotes)%>
								<%= Html.TextAreaFor(model => Model.PropertyInfo.ReactivationNotes, new { @class = "narrow" })%>
							</div>
							<div class="row">
								<div style="float:left">
									<%= Html.LabelFor(model => Model.PropertyInfo.ReactivationDate)%>
									<span class="read-only"><%=StringFormatter.LocalDate(Model.PropertyInfo.ReactivationDate)%></span>
								</div>
								<div style="float:right;">
								<input id="cancelOrReactivate" type="submit" name="cancelOrReactivate" value="<% if (Model.PropertyInfo.IsCancelled == true) { Response.Write("Reactivate Property"); } else { Response.Write("Cancel Property");  } %>" onclick="javascript:return(CancelOrReactivate());" class="button ui-corner-all ui-state-default " />
								</div>
							   </div>
						</fieldset>
					</div>
				</div>
				<div class="ui-tabs-panel ui-widget-content ui-corner-bottom" style="display:none;" id="landlord-tab">

						<legend>Landlord details</legend>

						<div class="left">
						 <fieldset class="wide">
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.LandlordName)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordName, new { maxlength = 100, @class = "textbox" })%>
								<span class="required landlordReqired">*</span>
  
							</div>    
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.LandlordEmail)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordEmail, new { maxlength = 400, @class = "textbox" })%>
								<span class="required landlordReqired">+</span>

							</div> 
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.LandlordTelephone)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordTelephone, new { maxlength = 50, @class = "textbox" })%>
								<span class="required landlordReqired">+</span>
							</div>
							 <div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.LandlordAddress)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordAddress, new { @class = "textbox" })%>
								 <span class="required landlordReqired">*</span>

							</div>    
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.LandlordSuburb)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordSuburb, new { maxlength = 50, @class = "textbox" })%>
								<span class="required landlordReqired">*</span>

							</div>    
							<div class="row">
								<label for="PropertyInfo_LandlordState_Id">Landlord State</label>
								<%= Html.DropDownList("PropertyInfo.LandlordState.Id", Model.LandlordStates, "-- Please Select --")%>
								<span class="required landlordReqired">*</span>

							</div>            
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.LandlordPostCode)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordPostCode, new { maxlength = 4, @class = "textbox small" })%>
								<span class="required landlordReqired">*</span>

							</div>   
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.LandlordCountry)%>
								<%= Html.TextBoxFor(model => model.PropertyInfo.LandlordCountry, new { maxlength = 50, @class = "textbox" })%>
								<span class="required landlordReqired">*</span>
							</div>   
						 </fieldset> 
						</div>
	  
				</div>
				<div class="clear"></div>
				<div class="buttons">
					<input type="button" name="ContactUsButton" value="Generate Letter" onclick="javascript:performBulkAction();" class="button ui-corner-all ui-state-default " />
					<input type="submit" name="ApplyButton" value="Save"  onclick="javascript:return (localValidate());" class="button ui-corner-all ui-state-default " />
					<input type="submit" name="SaveButton" value="Save &amp; Close" onclick="javascript:return(localValidate());" class="button ui-corner-all ui-state-default " />
					<input type="button" name="CancelButton" value="Cancel" onclick="javascript:openPropertyInfo(<%=Model.PropertyInfo.Id %>);" class="button ui-corner-all ui-state-default " />
				</div>
				<% } %>
		   </div>


<script type="text/javascript">

	var initialCanceledState ;
	var initialReActivatedState;

	$().ready(function () {
		initAddressAutoComplete('<%= Url.Action("GetSuburbs", "Suburb", new { area = "Admin" }) %>', '#PropertyInfo_State_Id', '#PropertyInfo_Suburb', '#PropertyInfo_PostCode');

		initAddressAutoComplete('<%= Url.Action("GetSuburbs", "Suburb", new { area = "Admin" }) %>', '#PropertyInfo_LandlordState_Id', '#PropertyInfo_LandlordSuburb', '#PropertyInfo_LandlordPostCode');

		
		jobTypeChanged();
		<% if (Model.PropertyInfo.JobType != 1) { %>
		$(".landlordReqired").show();
		<%}else{%>
		$(".landlordReqired").hide();
		<%}%>

		initialCanceledState = $('#PropertyInfo_IsCancelled').val(); 
		initialReActivatedState = $('#PropertyInfo_IsReactivated').val(); 
	});




	function CancelOrReactivate()
	{

		var cancelledField =  $('#PropertyInfo_IsCancelled');
		var reactivatedField =  $('#PropertyInfo_IsReactivated');
		//alert(cancelledField.val());
		if (cancelledField.val()=="True")
		{
			if (initialCanceledState=="False" )
			{
				//alert("Warning. You appear to have tried to Cancel or Reactivate a propery twice");
			}
			cancelledField.val("False");
			reactivatedField.val("True");

			$('#PropertyCancelledDisplay').text('Property has been Reactivated');
			$('#cancelOrReactivate').val('Cancel Property');
		}
		else
		{
			if (initialReActivatedState=="True" )
			{
				//alert("Warning. You appear to have tried to Cancel or Reactivate a propery twice");
			}
			cancelledField.val("True");
			reactivatedField.val("False");
			$('#PropertyCancelledDisplay').text('Property is Cancelled');
			$('#cancelOrReactivate').val('Reactivate Property');
		}
		return false;
	}

	function performBulkAction() {
		var selectedRows = '<%=Model.PropertyInfo.Id %>';
		var bulkAction = '<%=BulkAction.GenerateContactUsLetter.ToString("D") %>';

		var form = $('#bulk-form');
		$('#selectedRows').val(selectedRows);
		$('#bulkAction').val(bulkAction);
		form.submit();

	}

	function jobTypeChanged()
	{

		var jobType = $('#PropertyInfo_JobType');
		var agencyId = $('#AgencySelectRow');
		var privateLandlordAgency = $('#PrivateLandlordAgencySelectRow');
		var privateLandlordPropertyManager = $('#PrivateLandlordPropertyManagerSelectRow');
		var properrtManagerId = $('#PropertyManagerSelectRow');
		var PropertyInfo_billTo = $('#PropertyInfo_billTo');
		switch(parseInt(jobType.val()))
		{
			case <%= (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged.GetHashCode())  %>:
				
				if ($('#PropertyInfo_Agency_Id').val()=="<%= Model.PrivateLandlordsAgencyId %>")
				{
					$('#PropertyInfo_Agency_Id').val("");// Force this menu back to please select 
				}
				agencyId.show();
				properrtManagerId.show();
				PropertyInfo_billTo.hide();
				privateLandlordAgency.hide();
				privateLandlordPropertyManager.hide();
				$('#privateLandlordPropertyManager').val("<%= (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.PrivateLandlordBillToTypeEnum.BillToAgency.GetHashCode())  %>");// Alyways bill the agency (this is just her to please the validation)
				$(".landlordReqired").hide();
				break;
			case <%= (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.PrivateLandlordWithAgency.GetHashCode())  %>:
	
				//privateLandlordAgencyChanged();// Force update of the property Manager dropdown
				privateLandlordAgency.show();
				privateLandlordPropertyManager.show();

				//This is now done in the HomeController  $('#PropertyInfo_Agency_Id').val("<%= Model.PrivateLandlordsAgencyId %>");
				agencyId.hide();
				properrtManagerId.hide();
				PropertyInfo_billTo.show();
				$(".landlordReqired").show();
				break;
			case <%= (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.PrivateLandlordNoAgency.GetHashCode())  %>:
				agencyId.hide();
				properrtManagerId.hide();
				PropertyInfo_billTo.hide();
				privateLandlordAgency.hide();
				privateLandlordPropertyManager.hide();
				$(".landlordReqired").show();
				//This is now done in the HomeController   $('#PropertyInfo_Agency_Id').val("<%= Model.PrivateLandlordsAgencyId %>");
				$('#PropertyInfo_PrivateLandlordBillTo').val("<%= (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.PrivateLandlordBillToTypeEnum.BillToLandlord.GetHashCode())  %>");// // Alyways bill the landlord (this is just her to please the validation)
				break;
		}
	}
	
	function agencyChanged() {

		var agencyId = $('#PropertyInfo_Agency_Id').val();
		$.ajax({
			url: '<%= Url.Action("GetPropertyManagersForAgency", "Home", new { area="Agency", agencyId="_ID_", propertyInfoId = Model.PropertyInfo.Id }) %>'.replace(/_ID_/g, agencyId),
			dataType: 'json',
			success: function(result) {
				$('#PropertyInfo_PropertyManager_Id option').remove();
				$.each(result, function(i, item) {
					var option = '<option value="' + item.Value + '"';
					if(item.Selected == true) {
						option += ' selected="selected"';
					}
					option += '>' + item.Text + '</option>';
					$('#PropertyInfo_PropertyManager_Id').append(option);
				})
			}
		});
	}

	function privateLandlordAgencyChanged()
	{
		var agencyId = $('#PropertyInfo_PrivateLandlordAgency_Id').val();
		$.ajax({
			url: '<%= Url.Action("GetPropertyManagersForPrivateLandlordAgency", "Home", new { area="Agency", agencyId="_ID_", propertyInfoId = Model.PropertyInfo.Id }) %>'.replace(/_ID_/g, agencyId),
			dataType: 'json',
			success: function(result) {
				$('#PropertyInfo_PrivateLandlordPropertyManager_Id option').remove();
				$.each(result, function(i, item)
				{
					var option = '<option value="' + item.Value + '"';
					if(item.Selected == true) {
						option += ' selected="selected"';
					}
					option += '>' + item.Text + '</option>';
					$('#PropertyInfo_PrivateLandlordPropertyManager_Id').append(option);
				})
			}
		});

	}

	function localValidate()
	{

		if ($("#PropertyInfo_JobType").val()!="<%= (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged.GetHashCode())  %>")
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
		else
		{
			
			// Should now longer need to do this as the Private Landlords agency has been removed as an item from the list (in the model)
			if ($("#PropertyInfo_Agency_Id").val()== "<%= Model.PrivateLandlordsAgencyId %>")
			{
				alert("Please select a valid agency");
				return false;
			}

			return true;
		}
	}
	 
	function detailsTabClicked()
	{
		$("#landlord-tab").hide();
		$("#details-tab").show();
		$("#landlordTab").removeClass("ui-tabs-selected, ui-state-active");
		$("#detailsTab").addClass("ui-tabs-selected, ui-state-active");
	}

	function landlordTabClicked()
	{
		$("#details-tab").hide();
		$("#landlord-tab").show();

		$("#detailsTab").removeClass("ui-tabs-selected, ui-state-active");
		$("#landlordTab").addClass("ui-tabs-selected ui-state-active");


	}
	   
	</script>
</asp:Content>


