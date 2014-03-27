<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Agency.ViewModels.AgencyGroupViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.AgencyGroup.Id) + " Agency Group";
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%=Page.Title %></h2>
  	
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
	
    <% using (var form = Html.BeginForm("Edit", "AgencyGroup", FormMethod.Post, new { id = "edit-form" }))
       { %>           
            <%= Html.AntiForgeryToken() %>
            <%= Html.HiddenFor(model => model.AgencyGroup.RowVersion)%>
    
    <fieldset>      
            <legend>Properties</legend>  
            <div>
                <div class="row">
                    <%= Html.LabelFor(model => model.AgencyGroup.Name)%>
                    <%= Html.TextBoxFor(model => model.AgencyGroup.Name, new { maxlength = 100, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>            
            
            </div>

           
            <div class="buttons">
                <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                <%= Html.ActionButton("Cancel", "Index", "AgencyGroup", null, new { @class = "button ui-corner-all ui-state-default " })%>
            </div>
    </fieldset>           
    <% } %>
    
</asp:Content>


