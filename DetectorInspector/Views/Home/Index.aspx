<%@ Page Title="Log On" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.LoginViewModel>" %>

<asp:Content ID="loginContent" ContentPlaceHolderID="MainContent" runat="server">   
    
    <% using (Html.BeginForm("Index", "Home", new { returnUrl = Request.QueryString["ReturnUrl"] }, FormMethod.Post, new { id = "login-form" })) { %>
        
    <%= Html.AntiForgeryToken() %>
    <div id="login">
        <fieldset>
            <legend>Please Sign In</legend>
            
            <div class="row">
                <%= Html.LabelFor(m => m.UserName)%>
                <%= Html.TextBoxFor(m => m.UserName, new { maxlength = 150, @class = "textbox" })%>
                <%= Html.RequiredFieldIndicator() %>
            </div>
            
            <div class="row">
                <%= Html.LabelFor(m => m.Password)%>
                <%= Html.Password("Password", "", new { maxlength = 150, @class = "textbox" })%>
                <%= Html.RequiredFieldIndicator() %>
            </div>
            
             <div class="row noLabel">
			    <%= Html.ActionLink("Forgotten password?", "ForgottenPassword", "Account")%>
            </div>
            
            <div class="buttons">
                <input type="submit" value="Sign In" class="button ui-corner-all ui-state-default" />
            </div>
        
        </fieldset>
     </div>  
    <% } %>
    
</asp:Content>