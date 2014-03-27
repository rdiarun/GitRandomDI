<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl" %>
<%
    if (Request.IsAuthenticated) {
%>        
        <%= Html.ActionLink(Page.User.Identity.Name, "Profile", "Account", new { Area = "" }, null)%>
        <%= Html.ActionLink("Sign Out", "SignOut", "Account", new { area = "" }, new { onclick="confirmSignOut(this); return false;" })%>
<%
    }
    else {
%> 
        <%= Html.ActionLink("Sign In", "Index", "Home", new { area = "" }, null)%>
<%
    }
%>
