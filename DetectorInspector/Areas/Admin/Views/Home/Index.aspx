<%@ Page Title="Administration" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<h2>Administration</h2>

<ul>
    <li><%= Html.ActionLink("Import", "Index", "Import", new { area = "Admin" }, null)%></li>    
    <li><%= Html.RouteLink("Reference Data", "ManageReferenceDataHome")%></li>
    <li><%= Html.ActionLink("Notifications", "Index", "Notification", new { area = "Admin" }, null)%></li>
    <li><%= Html.ActionLink("Users", "Index", "User", new { area = "Admin" }, null)%></li>    
                                
</ul>



</asp:Content>
