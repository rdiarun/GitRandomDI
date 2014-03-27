<%@ Page Title="Edit User" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Admin.ViewModels.EditUserViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<%
    Page.Title = Html.GetCreateEditText(Model.Profile.Id) + " User";
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
	<h2><%=Page.Title %></h2>

	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
	
    <% using (var form = Html.BeginForm("Edit", "User", FormMethod.Post, new { id = "edit-form" })) { %>
        <%= Html.AntiForgeryToken() %>

    <div class="two-column">
        <div class="left">
            <fieldset>
                <legend>Account</legend>
                
                <div class="row">
                    <%= Html.LabelFor(model => Model.Profile.UserName)%>
                    <%= Html.TextBoxFor(model => Model.Profile.UserName, new { maxlength = 50, @class = "textbox" })%>
                </div>     
                
                <% if (!Html.IsEdit(Model.Profile.Id)) { %>
                
                    <div class="row">
                        <%= Html.LabelFor(model => model.Password)%>
                        <%= Html.Password("Password", "", new { maxlength = 50, @class = "textbox" })%>
                        <%= Html.RequiredFieldIndicator()%>
                    </div>     

                    <div class="row">
                        <%= Html.LabelFor(model => model.ConfirmPassword)%>
                        <%= Html.Password("ConfirmPassword", "", new { maxlength = 50, @class = "textbox" })%>
                        <%= Html.RequiredFieldIndicator()%>
                    </div> 
                <%} %>
                
                <div class="row">
                    <%= Html.LabelFor(model => Model.Profile.LastLoginUtcDate)%>
                    <span class="read-only">
                        <%= Html.UtcToLocalDateTime(Model.Profile.LastLoginUtcDate)%>
                    </span>
                </div>
                
                                
                <div class="row">
                    <label for="Profile_IsApproved">Account Approved:</label>
                    <%= Html.CheckBox("Profile.IsApproved", new { @class = "checkBox" })%>                
                </div> 
            
            </fieldset>         
            
            <fieldset>
                <legend>Roles</legend>
                
                <%= Html.CheckBoxList("Profile.Roles", Model.Roles, Model.Profile.Roles.Select<Role, string>(r => r.Id.ToString()), new { @class = "checkbox-list" })%>
                <div class="clear"></div>
            </fieldset>   
        </div>      
            
        <div class="right">
            <fieldset>
                <legend>Profile</legend>
           
                <div class="row">
                    <%= Html.LabelFor(model => Model.Profile.FirstName)%>
                    <%= Html.TextBoxFor(model => Model.Profile.FirstName, new { maxlength = 150, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>   

                <div class="row">
                    <%= Html.LabelFor(model => Model.Profile.LastName)%>
                    <%= Html.TextBoxFor(model => Model.Profile.LastName, new { maxlength = 150, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>   

                <div class="row">
                    <%= Html.LabelFor(model => Model.Profile.EmailAddress)%>
                    <%= Html.TextBoxFor(model => Model.Profile.EmailAddress, new { maxlength = 150, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>    
              

            </fieldset>
        </div>       
        
        <div class="clear"></div>
    </div>
    
    <div class="left">
        <div class="buttons">
        <% if (Html.IsEdit(Model.Profile.Id)) { %>
        
            <% if (Model.Profile.IsLockedOut)
               { %>
                <input type="button" id="unlock-account-button" value="Unlock Account" class="button ui-corner-all ui-state-default" onclick="unlockAccount();" />
            <% } %>
        
            <input type="button" value="Reset Password" class="button ui-corner-all ui-state-default" onclick="if (confirm('Reset the user\'s password?')) document.location='<%= Url.Action("ResetPassword", new {id = Model.Profile.Id}) %>';" />
            <input type="button" value="Change Password" class="button ui-corner-all ui-state-default" onclick="document.location='<%= Url.Action("ChangePassword", new {id = Model.Profile.Id}) %>';" />
            
        <% } %>
        </div>                    
    </div>
    
    <div class="right">                
        <div class="buttons">
            <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default" />
            <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default" />
            <%= Html.ActionButton("Cancel", "Index", "User", null, new { @class = "button ui-corner-all ui-state-default" })%>
        </div>                
    </div>
        
        <div class="clear"></div>                  
    <% } %>
    

        
    <script type="text/javascript">

            
        function unlockAccount() {
            $.ajax({
                dataType: 'json',
                url: '<%= Url.Action("UnlockAccount", new { id = Model.Profile.Id }) %>',
                success: function(result) {
                    if (result.success) {
                        $('#unlock-account-button').hide();

                        showInfoMessage('Success', 'The account has been unlocked.');
                    }
                }
            });
        }

    </script>
</asp:Content>