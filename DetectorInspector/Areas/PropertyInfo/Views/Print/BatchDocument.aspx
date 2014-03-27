<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Print.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.BatchViewModel>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<%
    var counter = 0;
    foreach(var document in Model.Documents){
%>
<%=document %>
<%    
    counter++;
    if (!counter.Equals(Model.Documents.Count()))
    {
        %>
        <div style="page-break-before:always">&nbsp;</div> 
        <%
    }
    }
%>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">

</asp:Content>
