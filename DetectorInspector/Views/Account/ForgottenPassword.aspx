<%@ Page Title="Forgotten Password" Language="C#" MasterPageFile="~/Views/Shared/Site.Master"  Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.ForgottenPasswordViewModel>"  %>

<asp:Content ID="loginContent" ContentPlaceHolderID="MainContent" runat="server">  

    <h2><%=Page.Title %></h2>
    
    <p>
        Use the form below to have your password reset and emailed to you. 
    </p>
 
    <%= Html.JQueryUIValidationSummary("Password change was unsuccessful. Please correct the errors and try again.", "forgot-password-form")%>

    <% using (Html.BeginForm("ForgottenPassword", "Account", FormMethod.Post, new { id = "forgot-password-form" }))
       { %>
        <%= Html.AntiForgeryToken() %>
                
        <fieldset>
            <legend>Forgotten password?</legend>
            
            <div class="row">
		        <%= Html.LabelFor(m => m.UserName)%>
		        <%= Html.TextBoxFor(m => m.UserName, new { maxlength = 150, @class = "textbox" })%>
		        <%= Html.ValidationMessageFor(m => m.UserName)%>
	        </div>
                                   
            <div class="buttons">		        
			    <input type="submit" value="Reset Password" class="button ui-corner-all ui-state-default" />		        
	        </div>
    
        </fieldset>
    
    <% } %>
      
    
</asp:Content>