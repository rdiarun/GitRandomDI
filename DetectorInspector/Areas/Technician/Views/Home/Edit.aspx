<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Technician.ViewModels.TechnicianViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
    <% 
        Page.Title = Html.GetCreateEditText(Model.Technician.Id) + " Technician";
    %>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <h2><%=Page.Title %></h2>

    <%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>

    <div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
        <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
            <li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Details</a></li>
            <% if (!Model.IsCreate())
               { %>
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Availability", "Index", "TechnicianAvailability", new { area = "Technician", id = Model.Technician.Id }, null)%></li>
            <%} %>
        </ul>

        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
            <% using (var form = Html.BeginForm("Edit", "Home", FormMethod.Post, new { id = "edit-form" }))
               { %>
            <%= Html.AntiForgeryToken() %>
            <%= Html.HiddenFor(model => model.Technician.RowVersion)%>
            <%= Html.Hidden("Profile.Roles", DetectorInspector.Model.SystemRole.Technician.ToString("D"))%>
            <%= Html.HiddenFor(model=>model.Technician.DefaultAvailability)%>

            <div class="left">

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

            </div>
            <div class="right">

                <div class="row">
                    <%= Html.LabelFor(model => Model.Profile.UserName)%>
                    <%= Html.TextBoxFor(model => Model.Profile.UserName, new { maxlength = 50, @class = "textbox" })%>
                    <%= Html.RequiredFieldIndicator()%>
                </div>

                <% if (!Html.IsEdit(Model.Profile.Id))
                   { %>

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

            </div>
            <div class="clear"></div>

            <div class="buttons">
                <% if (Html.IsEdit(Model.Profile.Id))
                   { %>

                <% if (Model.Profile.IsLockedOut)
                   { %>
                <input type="button" id="unlock-account-button" value="Unlock Account" class="button ui-corner-all ui-state-default" onclick="unlockAccount();" />
                <% } %>

                <input type="button" value="Reset Password" class="button ui-corner-all ui-state-default" onclick="if (confirm('Reset the user\'s password?')) document.location='<%= Url.Action("ResetPassword", "User", new {area = "Admin", id = Model.Profile.Id}) %>    ';" />
                <input type="button" value="Change Password" class="button ui-corner-all ui-state-default" onclick="document.location='<%= Url.Action("ChangePassword", "User", new { area ="Admin", id = Model.Profile.Id}) %>    ';" />

                <% } %>
            </div>
            <div class="clear"></div>
            <div class="left">

                <div class="row">
                    <%= Html.LabelFor(model => model.Technician.Company)%>
                    <%= Html.TextBoxFor(model => model.Technician.Company, new { maxlength = 100, @class = "textbox" })%>
                </div>
                <div class="row">
                    <%= Html.LabelFor(model => model.Technician.Telephone)%>
                    <%= Html.TextBoxFor(model => model.Technician.Telephone, new { maxlength = 12, @class = "textbox" })%>
                </div>
                <div class="row">
                    <%= Html.LabelFor(model => model.Technician.Mobile)%>
                    <%= Html.TextBoxFor(model => model.Technician.Mobile, new { maxlength = 12, @class = "textbox" })%>
                </div>
            </div>
            <div class="right">
                <div class="row">
                    <%= Html.LabelFor(model => model.Technician.Address)%>
                    <%= Html.TextBoxFor(model => model.Technician.Address, new { @class = "textbox" })%>
                </div>
                <div class="row">
                    <%= Html.LabelFor(model => model.Technician.Suburb)%>
                    <%= Html.TextBoxFor(model => model.Technician.Suburb, new { maxlength = 50, @class = "textbox" })%>
                </div>
                <div class="row">
                    <label for="Technician_State_Id">State</label>
                    <%= Html.DropDownList("Technician.State.Id", Model.States, "-- Please Select --")%>
                </div>
                <div class="row">
                    <%= Html.LabelFor(model => model.Technician.PostCode)%>
                    <%= Html.TextBoxFor(model => model.Technician.PostCode, new { maxlength = 4, @class = "textbox" })%>
                </div>
            </div>
        </div>
        <div class="buttons">
            <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
            <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
            <%= Html.ActionButton("Cancel", "Index", "Home", null, new { @class = "button ui-corner-all ui-state-default " })%>
        </div>
        <% } %>
    </div>


    <script type="text/javascript">


        function unlockAccount() {
            $.ajax({
                dataType: 'json',
                url: '<%= Url.Action("UnlockAccount", new { id = Model.Profile.Id }) %>',
            success: function (result) {
                if (result.success) {
                    $('#unlock-account-button').hide();

                    showInfoMessage('Success', 'The account has been unlocked.');
                }
            }
        });
    }

    </script>
</asp:Content>


