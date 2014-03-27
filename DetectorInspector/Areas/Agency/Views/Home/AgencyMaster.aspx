<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<table id="list"></table>
<div id="pager"></div>
<script type="text/javascript">
    var grid = $('#list');
    $().ready(function () {
        grid.jqGrid({
            url: '<%= Url.Action("GetItems") %>',
              colNames: ['Id', 'RowVersion', 'Agency Group', 'Name', 'Active Properties', 'Total Properties', 'Private landlord', 'Cancelled', '', '', '', ''],
              colModel: [
                  { name: 'id', index: 'Id', key: true, hidden: true, width: '40px' },
                  { name: 'rowVersion', index: 'RowVersion', hidden: true, width: '40px' },
                  { name: 'agencyGroup', index: 'AgencyGroup.Name', hidden: false, fixed: true, width: '190px', align: 'left', sortable: true, sorttype: 'text' },
                  { name: 'name', index: 'Name', hidden: false, width: '190px', fixed: true, align: 'left', sortable: true, sorttype: 'text' },
                  { name: 'activeCount', index: 'ActiveProperties.Count', hidden: false, fixed: true, width: '85px', align: 'right', sortable: false, sorttype: 'integer' },
                 { name: 'propertyCount', index: 'ActiveProperties.Count', hidden: false, fixed: true, width: '85px', align: 'right', sortable: false, sorttype: 'integer' },
                  { name: 'privateCount', index: 'ActiveProperties.Count', hidden: false, fixed: true, width: '85px', align: 'right', sortable: false, sorttype: 'integer' },
                  { name: 'isCancelled', index: 'IsCancelled', hidden: false, fixed: true, width: '60px', align: 'center', sortable: true, sorttype: 'text' },
                  { name: 'exportLink', width: '45px', fixed: true, resizable: false, align: 'center', sortable: false },
                  { name: 'editLink', width: '45px', fixed: true, resizable: false, align: 'center', sortable: false },
                  { name: 'cancelLink', width: '45px', fixed: true, resizable: false, align: 'center', sortable: false },
                  { name: 'deleteLink', width: '45px', fixed: true, resizable: false, align: 'center', sortable: false }
              ],
              pager: '#pager',
              sortname: 'Name',
              sortorder: 'asc',
              loadComplete: function () {
                  var dataIds = grid.getDataIDs();
                  var totalProperties = 0;
                  var activeProperties = 0;
                  for (var i = 0; i < dataIds.length; i++) {

                      var rowData = grid.getRowData(dataIds[i]);
                      totalProperties += parseInt(rowData.propertyCount);
                      activeProperties += parseInt(rowData.activeCount);

                      grid.setRowData(rowData.id, {
                          exportLink: '<a href="#" onclick="exportProperties(\'' + rowData.id + '\'); return false;" class="button-edit">Export</a>',
                          editLink: '<a href="<%= Url.Action("Edit") %>/' + rowData.id + '" class="button-edit">Edit</a>',
                            cancelLink: '<a href="#" onclick="confirmCancel(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-cancel">Cancel</a>'
                        });

                        if (rowData.propertyCount == 0) {
                            grid.setRowData(rowData.id, {
                                deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                            });
                        }
                    }

                    grid.setCell(0, 'agencyGroup', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'name', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'activeCount', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'propertyCount', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'privateCount', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'isCancelled', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'exportLink', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'editLink', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'deleteLink', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'cancelLink', '', { 'background-color': '#EEEEEE' }, '');
                    grid.setCell(0, 'modifiedUtcDate', '', { 'background-color': '#EEEEEE' }, '');
                },
              ondblClickRow: function (id) {
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
}
</script>

<fieldset style="font-size: 12px;">
    <legend>Totals</legend>
    <label style="width: 120px; display: inline-block; margin-bottom: 10px;">Active Properties:</label>
    <%=Model.ActivePropertiesTotal%><br />
    <label style="width: 120px; display: inline-block;">Total Properties:</label>
    <%= Model.PropertiesTotal %>
</fieldset>
<div id="dialog" style="display: none;" title="Delete Item">
    <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>Are you sure you want to delete the item &quot;<span id="deleteTitle"></span>&quot;?</p>
</div>
<div id="cancel-dialog" style="display: none;" title="Cancel Item">
    <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>Are you sure you want to cancel the item &quot;<span id="cancelTitle"></span>&quot;?</p>
</div>
