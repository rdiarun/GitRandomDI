<%@ Page Title="Edit Notification" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Model.Notification>" ValidateRequest="false" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    
    <%= Html.IncludeScript("~/Content/Scripts/tiny_mce/jquery.tinymce.js") %>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h2>Edit Notification</h2>

	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>

    <% using (var form = Html.BeginForm("Edit", "Notification", FormMethod.Post, new { id = "edit-form" } )) { %>
        <fieldset>
            <legend>Properties</legend>
        
            <%= Html.AntiForgeryToken() %>
            <%= Html.HiddenFor(model => model.RowVersion) %>
        
            <div class="row">
                <%= Html.LabelFor(model => model.Name) %>
                <%= Html.TextBoxFor(model => model.Name, new { maxlength = 150, @class = "textbox" })%>
                <%= Html.RequiredFieldIndicator() %>
            </div>            
                            
            <div class="row">
                <%= Html.LabelFor(model => model.Subject)%>
                <%= Html.TextBoxFor(model => model.Subject, new { maxlength = 150, @class = "textbox" })%>
                <%= Html.RequiredFieldIndicator() %>
            </div>   
            
            <div class="row">
                <%= Html.LabelFor(model => model.Body)%>
                <%= Html.TextAreaFor(model => model.Body, new { @class = "html-editor" })%>
                <%= Html.RequiredFieldIndicator() %>
            </div>   
                   
            <div class="buttons">
                <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                <%= Html.ActionButton("Cancel", "Index", "Notification", null, new { @class = "button ui-corner-all ui-state-default " })%>
            </div>
   
        </fieldset>
    <% } %>

    
    <div class="trail">
        <% Html.RenderPartial("AuditTrail", Model); %> |
    </div>
</asp:Content>


