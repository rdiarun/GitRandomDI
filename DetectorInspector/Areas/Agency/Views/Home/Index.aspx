<%@ Page Title="Agency Management" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.AgencyTotalsViewModel>" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Agency Management</h2>


    <% if ((SecurityExtensions.HasPermission(this.Context.User, Permission.SuperPermission) == true) && (SecurityExtensions.HasPermission(this.Context.User, Permission.AdministerSystem) == false))
       {%>

    <% Html.RenderPartial("AgencySuperUser"); %>
    <%} %>
    <% if (SecurityExtensions.HasPermission(this.Context.User, Permission.AdministerSystem) == true)
       {%>

    <% Html.RenderPartial("AgencyMaster"); %>
    <%} %>
    <div class="buttons">
        <%= Html.ActionButton("Add", "Edit", "Home", new { id = 0 }, new { @class = "button ui-corner-all ui-state-default" })%>
    </div>
    <% using (Html.BeginForm("Delete", "Home", FormMethod.Post, new { id = "action-form" }))
       {%>
    <%= Html.AntiForgeryToken()%>
    <% } %>
</asp:Content>


