<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Dialog.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.PageHelpViewModel>" %>

<asp:Content ID="Content4" ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.Help.Id) + " Help";
%>
</asp:Content>


<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <%= Html.IncludeScript("~/Content/Scripts/tiny_mce/jquery.tinymce.js") %>
    
    
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
    <% using (var form = Html.BeginForm("EditPage", "Help", new { code = Model.Help.Code }, FormMethod.Post, new { id = "edit-form" }))
       { %>
        <fieldset>
            <legend>Properties</legend>
        
            <%= Html.AntiForgeryToken() %>
            <%= Html.HiddenFor(model => Model.Help.RowVersion)%>
            <%= Html.HiddenFor(model => Model.Help.Code)%>
        
            <div class="left">
                <div class="row">
                    <%= Html.LabelFor(model => Model.Help.Title)%>
                    <%= Html.TextBoxFor(model => Model.Help.Title, new { maxlength = 150, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>            
            
                
                   
            <div class="row">
                <%= Html.LabelFor(model => Model.Help.Content)%>
                <%= Html.TextAreaFor(model => Model.Help.Content, new { @class = "html-editor" })%>
                <%= Html.RequiredFieldIndicator() %>
            </div>  
               
    
            
            </div>
        </fieldset>
    <% } %>
        
</asp:Content>