<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
    <% 
        Page.Title = Html.GetCreateEditText(Model.PropertyInfo.Id) + " Property: " + Model.PropertyInfo.ToString();
    %>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <h2><%=Page.Title %></h2>

    <%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>

    <div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
        <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
            <li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Details</a></li>
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Contact Details", "Index", "Contact", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <% if (!Model.IsCreate())
               { %>

            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Bookings & Service History", "ServiceSheet", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>

            <%} %>
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Landlord Details", "Landlord", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Change Log", "Index", "ChangeLog", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>

        </ul>
        <% using (Html.BeginForm("PerformBulkAction", "Home", FormMethod.Post, new { id = "bulk-form" }))
           {%>
        <%= Html.Hidden("bulkAction")%>
        <%= Html.Hidden("notificationDate")%>
        <%= Html.Hidden("selectedRows")%>

        <% } %>
        <% using (var form = Html.BeginForm("Edit", "Home", FormMethod.Post, new { id = "edit-form" }))
           { %>
        <%= Html.AntiForgeryToken() %>
        <%= Html.HiddenFor(model => model.PropertyInfo.RowVersion)%>
        <%= Html.Hidden("PropertyInfo.Zone.Id", Model.PropertyInfo.Zone != null ? Model.PropertyInfo.Zone.Id.ToString() : string.Empty)%>
        <%= Html.Hidden("PropertyInfo.LandlordState.Id", Model.PropertyInfo.LandlordState != null ? Model.PropertyInfo.LandlordState.Id.ToString() : string.Empty)%>

        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
            <div class="left">
                <fieldset class="narrow">
                    <legend>Property Details</legend>
                    <div class="row">
                        <%=Html.LabelFor(model=>model.PropertyInfo.PropertyNumber) %>
                        <span class="read-only"><%=Model.FormattedPropertyNumber %></span>

                    </div>

                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.JobType)%>
                        <span class="read-only"><%=Model.JobTypeName %></span>
                    </div>

                    <div class="row" id="PropertyInfo_billTo">
                        <%= Html.LabelFor(model => model.PropertyInfo.PrivateLandlordBillTo)%>
                        <span class="read-only"><%=Model.PrivateLandlordBillToTypeName %></span>
                    </div>
                    <% if (Model.PropertyInfo.JobType == (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged.GetHashCode()))
                       {  %>

                    <div class="row" id="AgencySelectRow">
                        <label for="PropertyInfo_Agency_Id">Agency</label>
                        <span class="read-only"><a href="<%= Url.Content("~/Agency/Home/Edit/" + Model.PropertyInfo.Agency.Id.ToString()) %>"><%=Model.PropertyInfo.Agency!=null?Model.PropertyInfo.Agency.Name:string.Empty %></a></span>
                    </div>
                    <div class="row" id="PropertyManagerSelectRow">
                        <label for="PropertyInfo_PropertyManager_Id">Property Manager</label>
                        <span class="read-only"><%=Model.PropertyInfo.PropertyManager!=null?Model.PropertyInfo.PropertyManager.Name:string.Empty %></span>
                    </div>

                    <%}
                       if (Model.PropertyInfo.JobType == (DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.PrivateLandlordWithAgency.GetHashCode()))
                       { %>
                    <div class="row" id="Div1">
                        <label for="PropertyInfo_Agency_Id">Agency</label>
                        <span class="read-only"><a href="<%= Url.Content("~/Agency/Home/Edit/" + Model.PropertyInfo.PrivateLandlordAgency.Id.ToString())%>"><%=Model.PropertyInfo.PrivateLandlordAgency != null ? Model.PropertyInfo.PrivateLandlordAgency.Name : string.Empty%></a></span>
                    </div>
                    <div class="row" id="Div2">
                        <label for="PropertyInfo_PropertyManager_Id">Property Manager</label>
                        <span class="read-only"><%=Model.PropertyInfo.PrivateLandlordPropertyManager != null ? Model.PropertyInfo.PrivateLandlordPropertyManager.Name : string.Empty%></span>
                    </div>

                    <% } %>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.UnitShopNumber)%>
                        <span class="read-only"><%=Model.PropertyInfo.UnitShopNumber %></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.StreetNumber)%>
                        <span class="read-only"><%=Model.PropertyInfo.StreetNumber%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.StreetName)%>
                        <span class="read-only"><%=Model.PropertyInfo.StreetName%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.Suburb)%>
                        <span class="read-only"><%=Model.PropertyInfo.Suburb%></span>
                    </div>
                    <div class="row">
                        <label for="PropertyInfo_State_Id">State</label>
                        <span class="read-only"><%=Model.PropertyInfo.State%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.PostCode)%>
                        <span class="read-only"><%=Model.PropertyInfo.PostCode%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.KeyNumber)%>
                        <span class="read-only"><%=Model.PropertyInfo.KeyNumber%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.Notes)%>
                        <span class="read-only"><%=Model.PropertyInfo.Notes %></span>
                    </div>
                    <!--
							<div class="row">
								<%= Html.LabelFor(model => model.PropertyInfo.Discount)%>
								<span class="read-only"><%=string.Format("{0:f2}", Model.PropertyInfo.Discount)%></span>
							</div>
							-->
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.DiscountPercentage)%>
                        <span class="read-only"><%=string.Format("{0:f2}", Model.PropertyInfo.DiscountPercentage)%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.HasLargeLadder)%>
                        <span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.HasLargeLadder)%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.LastServicedDate)%>
                        <span class="read-only"><%=StringFormatter.LocalDate(Model.PropertyInfo.LastServicedDate)%></span>
                    </div>

                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.IsFixedFeeService)%>
                        <span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.IsFixedFeeService)%></span>
                    </div>

                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.IsFreeService)%>
                        <span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.IsFreeService)%></span>
                    </div>
                </fieldset>
                <fieldset class="narrow" style="height: 174px;">
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
                <fieldset class="narrow">
                    <legend>Contact Details</legend>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.OccupantName)%>
                        <span class="read-only"><%=Model.PropertyInfo.OccupantName%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.ContactNotes)%>
                        <span class="read-only" style="height: 30px; display: inline-block; overflow: auto;"><%=Model.PropertyInfo.ContactNotes%></span>
                    </div>
                </fieldset>
                <fieldset class="narrow">
                    <legend>Miscellaneous</legend>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.SettlementDate)%>
                        <span class="read-only"><%=StringFormatter.LocalDate(Model.PropertyInfo.SettlementDate)%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.PropertyHoldDate)%>
                        <span class="read-only"><%=StringFormatter.LocalDate(Model.PropertyInfo.PropertyHoldDate)%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.JobCode)%>
                        <span class="read-only"><%=Model.PropertyInfo.JobCode%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.HasSendNotification)%>
                        <span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.HasSendNotification)%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.IsOneOffService)%>
                        <span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.IsOneOffService)%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.IsServiceCompleted)%>
                        <span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.IsServiceCompleted)%></span>
                    </div>
                </fieldset>
                <fieldset class="narrow">
                    <legend>Problem Details</legend>
                    <div class="row">
                        <%= Html.LabelFor(model => model.PropertyInfo.HasProblem)%>
                        <span class="read-only"><%=StringFormatter.BooleanToYesNo(Model.PropertyInfo.HasProblem)%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.ProblemNotes)%>
                        <span class="read-only" style="height: 30px; display: inline-block; overflow: auto;"><%=Model.PropertyInfo.ProblemNotes%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.ProblemStatusUpdatedDate)%>
                        <span class="read-only"><%=StringFormatter.LocalDateTime(Model.PropertyInfo.ProblemStatusUpdatedDate)%></span>
                    </div>
                </fieldset>
                <fieldset class="narrow">
                    <legend>Cancellation Details</legend>
                    <div class="row">
                        <span id="PropertyCancelledDisplay" style="font-weight: bold;"><%   if (Model.PropertyInfo.IsCancelled == true) { Response.Write("Property is Cancelled"); }
                                                                                            if (Model.PropertyInfo.IsReactivated == true) { Response.Write("Property has been Reactiavted"); }
                                                                                            if (Model.PropertyInfo.IsReactivated == false && Model.PropertyInfo.IsCancelled == false) { Response.Write("Property is Active"); }  %></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.CancellationNotes)%>
                        <span class="read-only" style="height: 30px; display: inline-block; overflow: auto;"><%=Model.PropertyInfo.CancellationNotes%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.CancellationDate)%>
                        <span class="read-only"><%=StringFormatter.LocalDate(Model.PropertyInfo.CancellationDate)%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.ReactivationNotes)%>
                        <span class="read-only" style="height: 30px; display: inline-block; overflow: auto;"><%=Model.PropertyInfo.ReactivationNotes%></span>
                    </div>
                    <div class="row">
                        <%= Html.LabelFor(model => Model.PropertyInfo.ReactivationDate)%>
                        <span class="read-only"><%=StringFormatter.LocalDate(Model.PropertyInfo.ReactivationDate)%></span>
                    </div>
                </fieldset>
            </div>
        </div>
        <div class="clear"></div>
        <div class="buttons">
            <input type="button" name="ContactUsButton" value="Generate Letter" onclick="javascript:performBulkAction();" class="button ui-corner-all ui-state-default " />
            <input type="button" name="EditButton" value="Edit" onclick="javascript:editPropertyInfo(<%=Model.PropertyInfo.Id %>);" class="button ui-corner-all ui-state-default " />
            <input type="button" name="CancelButton" value="Cancel" onclick="javascript: window.close();" class="button ui-corner-all ui-state-default " />
        </div>
        <% } %>
    </div>


    <script type="text/javascript">
        var _applicationRoot = '<%=Page.ResolveUrl("~/") %>';


        function editPropertyInfo(id) {

			
            var url = '<%= Url.Action("Edit", "Home", new { area = "PropertyInfo", id = "__ID__" }) %>'.replace(/__ID__/g, id);
		    window.location = url;

		}

		function performBulkAction() {
		    var selectedRows = '<%=Model.PropertyInfo.Id %>';
		    var bulkAction = '<%=BulkAction.GenerateContactUsLetter.ToString("D") %>';

		    var form = $('#bulk-form');
		    $('#selectedRows').val(selectedRows);
		    $('#bulkAction').val(bulkAction);
		    form.submit();

		}

		$().ready(function () {


		    var agencyId = $('#AgencySelectRow');
		    var properrtManagerId = $('#PropertyManagerSelectRow');
		    var PropertyInfo_billTo = $('#PropertyInfo_billTo');
		    switch(parseInt(<%= (Model.JobTypeNum) %>))
				{
				    case 1:
				        agencyId.show();
				        properrtManagerId.show();
				        PropertyInfo_billTo.hide();
				        $('#PropertyInfo_PrivateLandlordBillTo').val("2");// Alyways bill the agency (this is just her to please the validation)
				        break;
				    case 2:
	
				        agencyId.show();
				        properrtManagerId.show();
				        PropertyInfo_billTo.show();
				        break;
				    case 3:
				        agencyId.hide();
				        properrtManagerId.hide();
				        PropertyInfo_billTo.hide();
				        $('#PropertyInfo_PrivateLandlordBillTo').val("1");// // Alyways bill the agency (this is just her to please the validation)
				        break;
				}
	
		});
	


    </script>
</asp:Content>


