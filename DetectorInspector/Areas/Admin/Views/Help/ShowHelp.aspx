<%@ Page  Language="C#"  MasterPageFile="~/Views/Shared/Dialog.Master"  Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Model.Help>" %>

<asp:Content ID="Content4" ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Model.Title;
%>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
    <p>
       <% =Model.Content%>
    </p>
    
</asp:Content>