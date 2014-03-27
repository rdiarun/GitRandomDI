<%@ Page Title="Change Password" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.ChangePasswordViewModel>" %>

<asp:Content ID="changePasswordContent" ContentPlaceHolderID="MainContent" runat="server">
   
   <h2><%=Html.Encode(Page.Title) %></h2>
     
    <%= Html.JQueryUIValidationSummary("Password change was unsuccessful. Please correct the errors and try again.", "editForm")%>

    <% using (Html.BeginForm("ChangePassword", "Account", FormMethod.Post, new { id = "editForm", autocomplete = ConfigurationManager.AppSettings["autocomplete"] }))
       { %>
	        <%= Html.AntiForgeryToken() %>
            
            <fieldset>
				<legend>Change Password</legend>
           
                <div class="row">
                    <%= Html.LabelForKiandra(model => model.ExistingPassword)%>
                    <%= Html.Password("ExistingPassword", "", new { maxlength = 50, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator()%>
                </div>
                
                <div class="row">
                    <%= Html.LabelForKiandra(model => model.Password)%>
                    <%= Html.Password("Password", "", new { maxlength = 50, @class = "textbox" })%>                    
                    <%= Html.RequiredFieldIndicator()%>                    
                </div>
        
                <div class="row">
                    <%= Html.LabelForKiandra(model => model.ConfirmPassword)%>
                    <%= Html.Password("ConfirmPassword", "", new { maxlength = 50, @class = "textbox" })%>                    
                    <%= Html.RequiredFieldIndicator()%>
                </div>
                                                     
            </fieldset>
                           
            <div class="buttons">
		        <input type="submit" name="SaveButton" value="Save" class="button ui-corner-all ui-state-default" />
                <%= Html.ActionButton("Cancel", "Profile", null, null, new { @class = "button ui-corner-all ui-state-default" })%>
            </div>
            
    <% } %>
     
</asp:Content>