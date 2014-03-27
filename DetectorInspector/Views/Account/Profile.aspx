<%@ Page Title="Profile" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.RegisterViewModel>" %>


<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
			
    <%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "form") %>

    <% using (var form = Html.BeginForm("Profile", "Account", FormMethod.Post, new { id = "form" }))
       { %>
        
        <%= Html.AntiForgeryToken() %>
        <%= Html.HiddenFor(model => model.Profile.RowVersion) %>
                
        <fieldset>
            <legend>Account</legend>
                    
            <div class="row">
                <%= Html.LabelForKiandra(model => model.Profile.UserName)%>
                <%= Html.TextBoxFor(model => model.Profile.UserName, new { maxlength = 150, @class = "textbox" })%>
                <%= Html.RequiredFieldIndicator()%>
            </div>            
                       
        </fieldset>
        
        <fieldset>
            <legend>Profile</legend>
            
            <% Html.RenderPartial("UserProfile", Model); %>
                   
        </fieldset>
                   

        
        
                   
        <div class="buttons">                    
            <div class="left">
                <input type="button" value="Change Password" onclick="document.location='<%= Url.Action("ChangePassword", new {id = Model.Profile.Id}) %>';" class="button ui-corner-all ui-state-default" />
            </div>
            <div class="right">
                <input type="submit" name="SaveButton" value="Save" class="button ui-corner-all ui-state-default" />
            </div>
        </div>
    
     <% } %>  
 
</asp:Content>