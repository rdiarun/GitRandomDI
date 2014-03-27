<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Admin.ViewModels.RoleViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.Role.Id) + " Role";
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%=Page.Title %></h2>
  	
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
	
    <% using (var form = Html.BeginForm("Edit", "Role", FormMethod.Post, new { id = "edit-form" }))
       { %>           
            <%= Html.AntiForgeryToken() %>
            <%= Html.HiddenFor(model => model.Role.RowVersion)%>
            
            <div>
                <div class="row">
                    <%= Html.LabelFor(model => model.Role.Name)%>
                    <%= Html.TextBoxFor(model => model.Role.Name, new { maxlength = 150, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>            
            
                <div class="row">
                    <%= Html.LabelFor(model => model.Role.Description)%>
                    <%= Html.TextAreaFor(model => model.Role.Description)%>
                </div>   
            </div>
            <div>  
                <fieldset>
                    <legend>Permissions</legend>                
                    <% foreach (var area in Model.Areas) { %>      
                        <p><b><%= Html.Encode(area.Name) %></b></p>                
                        <p>
                            <%= Html.CheckBoxList("Role.Permissions", area.Permissions, Model.Role.Permissions.Select<Permission, string>(r => r.ToString("D")), new { @class = "checkbox-list permissions" })%>
                        </p>
                        <div class="clear">&nbsp;</div>
                    <% } %>
                </fieldset>
            </div>    
           
            <div class="buttons">
                <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                <%= Html.ActionButton("Cancel", "Index", "Role", null, new { @class = "button ui-corner-all ui-state-default " })%>
            </div>
           
    <% } %>
    
    <div class="trail">
        <% Html.RenderPartial("AuditTrail", Model.Role); %> |
    </div>
</asp:Content>


