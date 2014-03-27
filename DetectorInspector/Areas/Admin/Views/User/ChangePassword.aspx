<%@ Page Title="Change User Password" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Admin.ViewModels.ChangeUserPasswordViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<%
    Page.Title = "Change Password: " + Model.Profile.FullName;
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
	<h2><%=Page.Title %></h2>

	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
	
    <% using (var form = Html.BeginForm("ChangePassword", "User", FormMethod.Post, new { id = "edit-form" })) { %>
        
    <%= Html.AntiForgeryToken() %>
       
    <fieldset>
        <legend>Change Password</legend>
                        
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
            
    </fieldset>
              
   
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