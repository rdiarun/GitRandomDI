<%@ Page Title="User Management" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Admin.ViewModels.UserSearchViewModel>" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <h2>User Management</h2>

    <div class="search-criteria">
        <fieldset style="width: 150px;">
            <legend>Enabled Status</legend>
            
            <div class="row">
                <span class="radiobutton-list">
                    <input type="radio" id="Enabled_All" name="Enabled" value="" class="checkbox" <%= Model.Enabled == null ? "checked=\"true\"" : "" %> /><label for="Enabled_All">All</label>
                    <input type="radio" id="Enabled_True" name="Enabled" value="true" class="checkbox" <%= Model.Enabled.HasValue && Model.Enabled.Value ? "checked=\"true\"" : "" %> /><label for="Enabled_True">Enabled</label>
                    <input type="radio" id="Enabled_False" name="Enabled" value="false" class="checkbox" <%= Model.Enabled.HasValue && !Model.Enabled.Value ? "checked=\"true\"" : "" %> /><label for="Enabled_False">Disabled</label>
                </span>
            </div>        
        </fieldset>
        
        <fieldset  style="width: 150px;">
            <legend>Locked Out Status</legend>
            
            <div class="row">
                <span class="radiobutton-list">
                    <input type="radio" id="LockedOut_All" name="LockedOut" value="" class="checkbox" <%= Model.LockedOut == null ? "checked=\"true\"" : "" %> /><label for="LockedOut_All">All</label>
                    <input type="radio" id="LockedOut_True" name="LockedOut" value="true" class="checkbox" <%= Model.LockedOut.HasValue && Model.LockedOut.Value ? "checked=\"true\"" : "" %> /><label for="LockedOut_True">Locked Out</label>
                    <input type="radio" id="LockedOut_False" name="LockedOut" value="false" class="checkbox" <%= Model.LockedOut.HasValue && !Model.LockedOut.Value ? "checked=\"true\"" : "" %> /><label for="LockedOut_False">Not Locked Out</label>
                </span>
            </div>
        
        </fieldset> 
        
        <fieldset style="width: 408px;">
            <legend>Roles</legend>        
            <div class="row">
                <%= Html.CheckBoxList("SelectedRoles", Model.Roles, new { @class = "checkbox-list" }) %>
            </div>        
        </fieldset>
        
        <div class="buttons">            
			    <%= Html.ActionButton("Add", "Edit", "User", null, new { @class = "button ui-corner-all ui-state-default" })%>
		    
                <input type="button" onclick="search();" value="Search" class="button ui-corner-all ui-state-default" />
                <input type="button" onclick="clearSearch();" value="Clear" class="button ui-corner-all ui-state-default" />
        </div>        
        
    </div>
	

    <table id="list"></table>
    <div id="pager"></div>

<% using (Html.BeginForm("Delete", "User", FormMethod.Post, new { id = "delete-form" }))
   {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("RowVersion")%>
<% } %>

<script type="text/javascript">
    var grid = $('#list');

    $().ready(function () {
        grid.jqGrid({
            url: '<%= Url.Action("GetItems") %>',

            colNames: ['Id', 'RowVersion', 'First Name', 'Surname', 'User Name', 'Email Address', 'System', 'Enabled', 'Locked', 'Last Login', '', ''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: 40 },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                { name: 'firstName', index: 'FirstName', width: 100, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'lastName', index: 'LastName', width: 100, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'userName', index: 'UserName', width: 100, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'email', index: 'EmailAddress', width: 150, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'isSystem', index: 'IsSystem', hidden: false, width: '55px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'isApproved', index: 'IsApproved', width: '55px', fixed: true, align: 'center', sortable: false, sorttype: 'text' },
                { name: 'isLockedOut', index: 'IsLockedOut', width: '55px', fixed: true, align: 'center', sortable: false, sorttype: 'text' },
                { name: 'lastLoginUtcDate', index: 'LastLoginUtcDate', hidden: false, width: '100px', fixed: true, align: 'left', sortable: true, sorttype: 'date' },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#pager',
            sortname: 'LastName',
            sortorder: 'asc',
            loadComplete: function () {
                var dataIds = grid.getDataIDs();

                for (var i = 0; i < dataIds.length; i++) {
                    var rowData = grid.getRowData(dataIds[i]);

                    grid.setRowData(rowData.id, {
                        editLink: '<a href="<%= Url.Action("Edit") %>/' + rowData.id + '" class="button-edit">Edit</a>'
                    });

                    if (rowData.isSystem != 'Yes') {
                        grid.setRowData(rowData.id, {
                            deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.userName) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                        });
                    }
                }
            },
            ondblClickRow: function (id) {
                goToUser(id);
            }
        })

        grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

        $('#dialog').dialog({
            height: 200,
            autoOpen: false
        });
        search();
    });

    function search() {
        var teamId = $('#SelectedTeamId').val();
        var officeId = $('#SelectedOfficeContactId').val();
        var enabled = getRadioButtonListValue('Enabled');
        var lockedOut = getRadioButtonListValue('LockedOut');
        var roles = getCheckBoxListValues('SelectedRoles');

        grid.jqGrid("setGridParam", { postData: null });
        grid.jqGrid("setGridParam", {
            postData: {
                SelectedTeamId: teamId,
                SelectedOfficeContactId: officeId,
                SelectedRoles: roles,
                Enabled: enabled,
                LockedOut: lockedOut
            }
        });

        reloadGrid(grid);
    }

    function clearSearch() {
      
        $('#Enabled_All')[0].checked = true;
        $('#LockedOut_All')[0].checked = true;

        $('input[name=SelectedRoles]').each(function() {
            this.checked = true;
        });
                
        search();
    }


    function goToUser(id) {
        document.location.href = '<%= Url.Action("Edit") %>/' + id;
    }

    function confirmDelete(id, name, rowVersion) {
        $('#deleteTitle').text(unescape(name));

        var deleteDialog = $('#dialog');

        deleteDialog.dialog('option', 'buttons',
        {
            'No': function () {
                $(this).dialog('close');
            },
            'Yes': function () {
                $(this).dialog('close');

                var rowVersionHidden = $('#RowVersion')[0];

                rowVersionHidden.value = rowVersion;

                var form = $('#delete-form')[0];

                form.action = '<%= Url.Action("Delete") %>/' + id;
                form.submit();
            }
        });

        deleteDialog.dialog('open');
    }

</script>

<div id="dialog" style="display:none;" title="Delete User">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to delete the user &quot;<span id="deleteTitle"></span>&quot;?</p>
</div>

</asp:Content>