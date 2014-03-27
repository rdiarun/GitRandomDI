<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Model.ILookupEntity>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText<int>() + ViewData["EntityTypeDisplayName"];
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%= Html.Encode(Page.Title) %></h2>
    
    <%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form") %>

    <% using (var form = Html.BeginForm("Edit", "ReferenceData", new { id = Model.Id }, FormMethod.Post, new { id = "edit-form" })) { %>
        <fieldset>
            <legend>Properties</legend>
        
            <%= Html.AntiForgeryToken() %>
            <%= Html.HiddenFor(model => model.RowVersion) %>
            
            <div class="left">
                <div class="row">
                    <%= Html.LabelFor(model => model.Name) %>
                    <%= Html.TextBoxFor(model => model.Name, new { maxlength = 150, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>            
            

                <div class="row">
                    <%= Html.LabelFor(model => model.IsDeleted) %>
                    <%= Html.CheckBox("IsDeleted", new { @class = "checkBox" })%>
                </div>    
                
                <div class="buttons">
                    <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                    <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                    <%= Html.ActionButton("Cancel", "List", "ReferenceData", new { entityType = Model.GetType().Name }, new { @class = "button ui-corner-all ui-state-default " })%>
                </div>

            </div>
        </fieldset>
    <% } %>
    <div class="trail">
        <% Html.RenderPartial("AuditTrail", Model); %> | 
    </div>
</asp:Content>


