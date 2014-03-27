    <%@ Page Title="Administration" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Admin.ViewModels.ImportViewModel>" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<h2>Import</h2>
    <%= Html.IncludeScript("~/Content/Scripts/jquery.blockUI.js")%>	
    <%= Html.IncludeScript("~/Content/Scripts/jquery.json.js")%>	


	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "import-form")%>
    <% using (var form = Html.BeginForm("Index", "Import", FormMethod.Post, new { id = "import-form", enctype = "multipart/form-data" } )) { %>
        
    <fieldset>
        <legend>Import Properties</legend>
    
        <%= Html.AntiForgeryToken() %>
        
        <% if (Model.ShowClearDatabaseButton) { %>                
        <div class="buttons">
             <input type="button" id="clear-database" value="Clear Database" class="button ui-corner-all ui-state-default" />
        </div> 
        <% } %>

        <div class="left">
            <div class="row">
                <%=Html.LabelFor(model=>model.ImportType) %>
                <%= Html.RadioButtonList("ImportType",
	                                Model.ImportTypes,
                                    ImportType.NewProperties.ToString("D"),
	                                new { @class = "radiobutton-list", style="width: 682px;" })%>
            </div>
            <div class="row">
                <%=Html.LabelFor(model=>model.ImportFormat) %>
                <%= Html.RadioButtonList("ImportFormat",
	                                Model.ImportFormats,
                                    ImportFormat.Console2007.ToString("D"),
	                                new { @class = "radiobutton-list", style="width: 682px;" })%>
            </div>
            <div class="row">
                <%=Html.LabelFor(model=>model.Agency) %>
                <%=Html.DropDownList("Agency.Id", Model.Agencies, "--Please select--" ) %>
            </div>
            <div class="row">
                <label>File</label>
                <input type="file" name="UploadedFile" />
            </div>
            <div class="buttons">
                <input type="submit" name="ApplyButton" value="Import" class="button ui-corner-all ui-state-default " />
            </div>

    </fieldset>
    <% } %>

    <script type="text/javascript">
        $(document).ready(function () {
            $(document).ajaxStop($.unblockUI);

            $('#clear-database').click(function () {
                $.blockUI({
                    message: '<h1><img src="/Content/Images/indicator.gif" /> Clearing your database... Please be patient...</h1>',
                    onBlock: function () {
                        clearDatabase();
                    },
                    onUnblock: function () {
                        alert('Database successfully cleared');
                    }
                });
            });

            function clearDatabase() {
                var action = '<%= Url.Action("ClearDatabase") %>';

                $.ajax({
                    url: action,
                    cache: false,
                    success: function (val) {
                        val = jQuery.parseJSON(val);

                        if (val.success !== true) {
                            alert('An error occured: ' + val.error);
                        }
                    },
                    failure: function (error) {
                        alert('Could not clear the database. An error occurred: ' + error.toString());
                    }
                });
            }
        });
    </script>
</asp:Content>
