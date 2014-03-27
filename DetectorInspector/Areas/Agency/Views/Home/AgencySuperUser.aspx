<%@ Page Title="" Language="C#" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<table id="listSuper"></table>
<div id="pagers"></div>
<script type="text/javascript">
    var gridSuper = $('#listSuper');
    $().ready(function () {
        gridSuper.jqGrid({
            url: '<%= Url.Action("GetItemsSuper") %>',
            colNames: ['Id', 'RowVersion', 'Agency Group', 'Name ', '', '', '', 'Cancelled', '', '', '', ''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: '40px' },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: '40px' },
                { name: 'agencyGroup', index: 'AgencyGroup.Name', hidden: false, fixed: true, width: '290px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'name', index: 'Name', hidden: false, width: '290px', fixed: true, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'activeCount', index: 'ActiveProperties.Count', hidden: true, fixed: true, width: '85px', align: 'right', sortable: false, sorttype: 'integer' },
               { name: 'propertyCount', index: 'ActiveProperties.Count', hidden: true, fixed: true, width: '85px', align: 'right', sortable: false, sorttype: 'integer' },
                { name: 'privateCount', index: 'ActiveProperties.Count', hidden: true, fixed: true, width: '85px', align: 'right', sortable: false, sorttype: 'integer' },
                { name: 'isCancelled', index: 'IsCancelled', hidden: false, fixed: true, width: '60px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'exportLink', width: '45px', fixed: true, hidden: true, resizable: false, align: 'center', sortable: false },
                { name: 'editLink', width: '45px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'cancelLink', width: '45px', fixed: true, hidden: true, resizable: false, align: 'center', sortable: false },
                { name: 'deleteLink', width: '45px', fixed: true, hidden: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#pagers',
            sortname: 'Name',
            sortorder: 'asc',
            loadComplete: function () {
                var dataIds = gridSuper.getDataIDs();
                var totalProperties = 0;
                var activeProperties = 0;

                for (var i = 0; i < dataIds.length; i++) {

                    var rowData = gridSuper.getRowData(dataIds[i]);
                    totalProperties += parseInt(rowData.propertyCount);
                    activeProperties += parseInt(rowData.activeCount);

                    gridSuper.setRowData(rowData.id, {
                        exportLink: '<a href="#" onclick="exportProperties(\'' + rowData.id + '\'); return false;" class="button-edit">Export</a>',
                        editLink: '<a href="<%= Url.Action("Edit") %>/' + rowData.id + '" class="button-edit">Edit</a>',
                            cancelLink: '<a href="#" onclick="confirmCancel(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-cancel">Cancel</a>'
                        });

                        if (rowData.propertyCount == 0) {
                            gridSuper.setRowData(rowData.id, {
                                deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                            });
                        }
                    }

                    gridSuper.setCell(0, 'agencyGroup', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'name', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'activeCount', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'propertyCount', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'privateCount', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'isCancelled', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'exportLink', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'editLink', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'deleteLink', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'cancelLink', '', { 'background-color': '#EEEEEE' }, '');
                    gridSuper.setCell(0, 'modifiedUtcDate', '', { 'background-color': '#EEEEEE' }, '');
                },
            ondblClickRow: function (id) {
                gotToItem(id);
            }
        })

        gridSuper.jqGrid('navGrid', '#pagers', { search: false, edit: false, add: false, del: false });

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
    'No': function () {
        $(this).dialog('close');
    },
    'Yes': function () {
        $(this).dialog('close');

        var rowVersionHidden = $('#RowVersion')[0];


        rowVersionHidden.value = rowVersion;

        var form = $('#action-form')[0];

        form.action = '<%= Url.Action("Cancel") %>/' + id;
        form.submit();
    }
});
    cancelDialog.dialog('open');
}
function exportProperties(id) {

    var form = $('#action-form')[0];
    form.action = '<%= Url.Action("ExportProperties") %>/' + id;
    form.submit();
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

        var form = $('#action-form')[0];

        form.action = '<%= Url.Action("Delete") %>/' + id;
        form.submit();
    }
});
    deleteDialog.dialog('open');
}
function gotToItem(id) {
    document.location.href = '<%= Url.Action("Edit") %>/' + id;
}                      </script>
<fieldset style="font-size: 12px; visibility: hidden; display: none;">
    <legend>Totals 111</legend>
    <label style="width: 120px; display: inline-block; margin-bottom: 10px;">Active Properties:</label>
    <%=Model.ActivePropertiesTotal%><br />
    <label style="width: 120px; display: inline-block;">Total Properties:</label>
    <%= Model.PropertiesTotal %>
</fieldset>
