<%@ Page Title="Register" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.RegisterViewModel>" %>


<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
			
    <%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "form") %>

    <% using (var form = Html.BeginForm("Register", "Account", FormMethod.Post, new { id = "form" }))
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
        
            <div class="row">
                <%= Html.LabelForKiandra(model => model.Password)%>
                <%= Html.Password("Password", null, new { maxlength = 50, @class = "textbox" })%>
                <%= Html.RequiredFieldIndicator()%>
            </div>
            
            <div class="row">
                <%= Html.LabelForKiandra(model => model.PasswordConfirm)%>
                <%= Html.Password("PasswordConfirm", null, new { maxlength = 50, @class = "textbox" })%>
                <%= Html.RequiredFieldIndicator()%>
            </div>
                       
        </fieldset>
        
        <fieldset>
            <legend>Profile</legend>
            
            <% Html.RenderPartial("UserProfile", Model); %>
                   
        </fieldset>
                   
        <div class="buttons">                    
            <input type="submit" name="SaveButton" value="Register" class="button ui-corner-all ui-state-default" />                        
        </div>
    
     <% } %>  
 
</asp:Content>