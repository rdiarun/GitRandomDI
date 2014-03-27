<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Model.Help>" %>

<asp:Content ID="Content4" ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText<Guid>() + " Help";
%>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
    <h2>Create Help</h2>
    
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
    <% using (var form = Html.BeginForm("Edit", "Help", FormMethod.Post, new { id = "edit-form" } )) { %>
        <fieldset>
            <legend>Properties</legend>
        
            <%= Html.AntiForgeryToken() %>
            <%= Html.HiddenFor(model => model.RowVersion) %>
        
            <div class="left">
                <div class="row">
                    <%= Html.LabelFor(model => model.Title) %>
                    <%= Html.TextBoxFor(model => model.Title, new { maxlength = 150, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>            
            
                <div class="row">
                    <%= Html.LabelFor(model => model.Content)%>
                    <%= Html.TextAreaFor(model => model.Content)%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>   
                
                
                <div class="buttons">
                    <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                    <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                    <%= Html.ActionButton("Cancel", "Index", "Help", null, new { @class = "button ui-corner-all ui-state-default " })%>
                </div>
            
            </div>
        </fieldset>
    <% } %>
    
    <div class="trail">
        <% Html.RenderPartial("AuditTrail", Model); %> |
    </div>
</asp:Content>


