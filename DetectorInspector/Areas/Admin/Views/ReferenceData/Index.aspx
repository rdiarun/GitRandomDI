<%@ Page Title="Reference Data" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<h2>Reference Data</h2>

<ul>
    <li><%= Html.ActionLink("Service Item", "Index", "ServiceItem", new { area = "Admin" }, null)%></li>
    <li><%= Html.ActionLink("Suburbs", "Index", "Suburb", new { area = "Admin" }, null) %></li>
</ul>

</asp:Content>