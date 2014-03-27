<%@ Page Title="Technician Management" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>




<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

<h2>Technician Management</h2>

<table id="list"></table>
<div id="pager"></div>

<div class="buttons">
	 <%= Html.ActionButton("Add", "Edit", "Home", new { id = 0 }, new { @class = "button ui-corner-all ui-state-default" })%>		 
</div>

<% using (Html.BeginForm("Delete", "Home", FormMethod.Post, new { id = "delete-form" }))
   {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("RowVersion")%>
<% } %>

<% using (Html.BeginForm("Cancel", "Home", FormMethod.Post, new { id = "cancel-form" }))
   {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("RowVersion")%>
<% } %>

<script type="text/javascript">
    var grid = $('#list');

    $().ready(function() {
        grid.jqGrid({
            url: '<%= Url.Action("GetItems") %>',
                       
            colNames: ['Id', 'RowVersion', 'Name', 'Company', 'Telephone', 'Mobile', 'Approved', '', '', ''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: 40 },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                { name: 'name', index: 'Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'company', index: 'Company', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'telephone', index: 'Telephone', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'mobile', index: 'Mobile', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'isApproved', index: 'IsApproved', hidden: false, width: '90px', align: 'center', sortable: false, sorttype: 'text' },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'cancelLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#pager',
            sortname: 'Name',
            sortorder: 'asc',
            loadComplete: function() {
                var dataIds = grid.getDataIDs();

                for (var i = 0; i < dataIds.length; i++) {

                    var rowData = grid.getRowData(dataIds[i]);

                    grid.setRowData(rowData.id, {
                        editLink: '<a href="<%= Url.Action("Edit") %>/' + rowData.id + '" class="button-edit">Edit</a>',
                        cancelLink: '<a href="#" onclick="confirmCancel(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Cancel</a>',
                        deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                    });
                }
            },
            ondblClickRow: function(id) {
                gotToItem(id);
            }
        })

        grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

        $('#dialog').dialog({
            modal: true,
            autoOpen: false
        });

        $('#cancel-dialog').dialog({
            modal: true,
            autoOpen: false
        });
    });

    
    function confirmCancel(id, name, rowVersion) {
        $('#cancelTitle').text(unescape(name));

        var cancelDialog = $('#cancel-dialog');

        cancelDialog.dialog('option', 'buttons',
        {
            'No': function() {
                $(this).dialog('close');
            },
            'Yes': function() {
                $(this).dialog('close');

                var rowVersionHidden = $('#RowVersion')[0];

                rowVersionHidden.value = rowVersion;

                var form = $('#cancel-form')[0];

                form.action = '<%= Url.Action("Cancel") %>/' + id;
                form.submit();
            }
        });

        cancelDialog.dialog('open');
    }


    function confirmDelete(id, name, rowVersion) {
        $('#deleteTitle').text(unescape(name));

        var deleteDialog = $('#dialog');

        deleteDialog.dialog('option', 'buttons',
        {
            'No': function() {
                $(this).dialog('close');
            },
            'Yes': function() {
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


    function gotToItem(id) {
        document.location.href = '<%= Url.Action("Edit") %>/' + id;
    }

</script>

<div id="dialog" style="display:none;" title="Delete Item">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to delete the item &quot;<span id="deleteTitle"></span>&quot;?</p>
</div>

<div id="cancel-dialog" style="display:none;" title="Cancel Item">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to cancel the item &quot;<span id="cancelTitle"></span>&quot;?</p>
</div>

</asp:Content>


