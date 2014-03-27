<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="InitContent" runat="server">
<% 
	Page.Title = Html.GetCreateEditText(Model.PropertyInfo.Id) + " Property: " + Model.PropertyInfo.ToString();
%>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
	
	<h2><%=Page.Title %></h2>
	
	<div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
		<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
			<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Details", "View", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
					<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Contact Details", "Index", "Contact", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
					<% if (!Model.IsCreate())
					   { %>          
					
					<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Bookings & Service History", "ServiceSheet", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
					
					<%} %>
			<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Landlord Details", "Landlord", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
			<li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><%= Html.ActionLink("Change Log", "Index", "ChangeLog", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>

		</ul>

		<div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
			<div class="left">
				<% Html.RenderPartial("ChangeLogEntry"); %>
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


