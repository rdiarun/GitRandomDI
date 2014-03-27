<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Admin.ViewModels.SuburbViewModel>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.Suburb.Id) + " Suburb";
%>
</asp:Content>

<asp:Content ID="Content6" ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%= Page.Title %></h2>
    
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
    <% using (var form = Html.BeginForm("Edit", "Suburb", FormMethod.Post, new { id = "edit-form" } )) { %>
        
    <fieldset>
        <legend>Properties</legend>
    
        <%= Html.AntiForgeryToken() %>
        <%= Html.HiddenFor(model => model.Suburb.RowVersion)%>
        
        <div class="left">
            <div class="row">
                <%= Html.LabelFor(model => model.Suburb.Name) %>
                <%= Html.TextBoxFor(model => model.Suburb.Name, new { maxlength = 150, @class = "textbox" })%>
                <%= Html.RequiredFieldIndicator() %>
            </div>            
        
            <div class="row">
                <%= Html.LabelFor(model => model.Suburb.PostCode)%>
                <%= Html.TextBoxFor(model => model.Suburb.PostCode, new { @class = "textbox postcode", maxlength = 4 })%>
            </div>   
            
            <div class="row">
                <%= Html.LabelFor(model => model.Suburb.State)%>
                <%= Html.DropDownList("Suburb.State.Id", Model.States, "-- Please Select --")%>
                <%= Html.RequiredFieldIndicator() %>
            </div>  
           
            <div class="row">
                <%= Html.LabelFor(model => model.Suburb.Zone)%>
                <%= Html.DropDownList("Suburb.Zone.Id", Model.Zones, "-- Please Select --")%>
                <%= Html.RequiredFieldIndicator() %>
            </div>  
           
            <div class="row">
                <%= Html.LabelFor(model => model.Suburb.IsDeleted) %>
                <%= Html.CheckBox("Suburb.IsDeleted", new { @class = "checkBox" })%>
            </div>      
             
            <div class="buttons">
                <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                <%= Html.ActionButton("Cancel", "Index", "Suburb", null, new { @class = "button ui-corner-all ui-state-default " })%>
            </div>
        
        </div> 
    </fieldset>
    <% } %>
    
    <div class="trail">
        <% Html.RenderPartial("AuditTrail", Model.Suburb); %> | 
    </div>
</asp:Content>