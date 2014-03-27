<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.PropertyInfo.Id) + " Property: " + Model.PropertyInfo.ToString();
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%=Page.Title %></h2>
  	
    <div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
        <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Details", "View", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Contact Details</a></li>
            
            <% if (!Model.IsCreate())
                { %>          
            
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Bookings & Service History", "ServiceSheet", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            
            <%} %>
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Landlord Details", "Landlord", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
			<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Change Log", "Index", "ChangeLog", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>

        </ul>
            
        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
            <div class="left">
                <% Html.RenderPartial("ContactEntry"); %>
            </div>
            <div class="right">
                <%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
                <% using (var form = Html.BeginForm("Index", "Contact", FormMethod.Post, new { id = "edit-form" }))
                { %>           
                    <%= Html.AntiForgeryToken() %>
                    <%= Html.HiddenFor(model => model.PropertyInfo.RowVersion)%>
                    <%= Html.Hidden("PropertyInfo.State.Id", Model.PropertyInfo.State != null ? Model.PropertyInfo.State.Id.ToString() : string.Empty)%>
                    <%= Html.Hidden("PropertyInfo.LandlordState.Id", Model.PropertyInfo.LandlordState != null ? Model.PropertyInfo.LandlordState.Id.ToString() : string.Empty)%>
                    <%= Html.Hidden("PropertyInfo.Agency.Id", Model.PropertyInfo.Agency != null ? Model.PropertyInfo.Agency.Id.ToString() : string.Empty)%>
                    <%= Html.Hidden("PropertyInfo.PropertyManager.Id", Model.PropertyInfo.PropertyManager != null ? Model.PropertyInfo.PropertyManager.Id.ToString() : string.Empty)%>
                    <%= Html.Hidden("PropertyInfo.Zone.Id", Model.PropertyInfo.Zone != null ? Model.PropertyInfo.Zone.Id.ToString() : string.Empty)%>
           			<%= Html.Hidden("PropertyInfo.PrivateLandlordAgency.Id", Model.PropertyInfo.PrivateLandlordAgency != null ? Model.PropertyInfo.PrivateLandlordAgency.Id.ToString() : string.Empty)%>
        			<%= Html.Hidden("PropertyInfo.PrivateLandlordPropertyManager.Id", Model.PropertyInfo.PrivateLandlordPropertyManager != null ? Model.PropertyInfo.PrivateLandlordPropertyManager.Id.ToString() : string.Empty)%>

                <div class="row">
                    <%= Html.LabelFor(model => model.PropertyInfo.OccupantName)%>
                    <%= Html.TextBoxFor(model => model.PropertyInfo.OccupantName, new { @class = "textbox narrow" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>    
                <div class="row">
                    <%= Html.LabelFor(model => model.PropertyInfo.OccupantEmail)%>
                    <%= Html.TextBoxFor(model => model.PropertyInfo.OccupantEmail, new { @class = "textbox narrow" })%>
                </div>    
                    <div class="row">
                    <%= Html.LabelFor(model => model.PropertyInfo.PostalAddress)%>
                    <%= Html.TextBoxFor(model => model.PropertyInfo.PostalAddress, new { @class = "textbox" })%>
                </div>    
                <div class="row">
                    <%= Html.LabelFor(model => model.PropertyInfo.PostalSuburb)%>
                    <%= Html.TextBoxFor(model => model.PropertyInfo.PostalSuburb, new { maxlength = 50, @class = "textbox" })%>
                </div>    
                <div class="row">
	                <label for="PropertyInfo_PostalState_Id">Postal State</label>
	                <%= Html.DropDownList("PropertyInfo.PostalState.Id", Model.PostalStates, "-- Please Select --")%>
                </div>            
                <div class="row">
                    <%= Html.LabelFor(model => model.PropertyInfo.PostalPostCode)%>
                    <%= Html.TextBoxFor(model => model.PropertyInfo.PostalPostCode, new { maxlength = 4, @class = "textbox small" })%>
                </div>   
                <div class="row">
                    <%= Html.LabelFor(model => model.PropertyInfo.PostalCountry)%>
                    <%= Html.TextBoxFor(model => model.PropertyInfo.PostalCountry, new { maxlength = 50, @class = "textbox" })%>
                </div>    
                <div class="clear"></div>
                <div class="buttons">
                    <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                    <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                    <input type="button" name="CancelButton" value="Cancel" onclick="javascript:openPropertyInfo(<%=Model.PropertyInfo.Id %>);" class="button ui-corner-all ui-state-default " />
                </div>
                <% } %>

            </div>
        </div>
        <div class="clear"></div>
    </div>


<script type="text/javascript">
    $().ready(function () {
        initAddressAutoComplete('<%= Url.Action("GetSuburbs", "Suburb", new { area = "Admin" }) %>', '#PropertyInfo_PostalState_Id', '#PropertyInfo_PostalSuburb', '#PropertyInfo_LandlordPostCode');
    });
</script>
</asp:Content>


