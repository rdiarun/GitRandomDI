<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Agency.ViewModels.AgencyViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.Agency.Id) + " Agency";
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%=Page.Title %></h2>
  	
    <div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
        <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Details", "Edit", "Home", new { area = "Agency", id = Model.Agency.Id }, null)%></li>
            <li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Property Managers</a></li>
        </ul>
            
        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
            <% Html.RenderPartial("PropertyManager"); %>
        </div>
    </div>
    
    <%--<div class="trail">
        <% Html.RenderPartial("AuditTrail", Model.Agency); %> |
    </div>--%>
</asp:Content>


