<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.AgencyTotalsViewModel>"  %>

<table id="list"></table>
<div id="pager"></div>

<script type="text/javascript">
    var grid = $('#list');
    $().ready(function () {
        grid.jqGrid({
            url: '<%= Url.Action("GetItems", "Home", new { area = "Agency" }) %>',

            colNames: ['Id', 'RowVersion', 'Agency Group', 'Name', 'Active Properties', 'Cancelled', '', '', '', ''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: '40px' },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: '40px' },
                { name: 'agencyGroup', index: 'AgencyGroup.Name', hidden: false, fixed: true, width: '190px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'name', index: 'Name', hidden: false, width: '190px', fixed: true, align: 'left', sortable: true, sorttype: 'text' },

                { name: 'isCancelled', index: 'IsCancelled', hidden: false, fixed: true, width: '60px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'exportLink', width: '45px', fixed: true, hidden: true, resizable: false, align: 'center', sortable: false },
                { name: 'editLink', width: '45px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'cancelLink', width: '45px', fixed: true, hidden: true, resizable: false, align: 'center', sortable: false },
                { name: 'deleteLink', width: '45px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#pager',
            sortname: 'Name',
            sortorder: 'asc',
            loadComplete: function () {
                var dataIds = grid.getDataIDs();
                var totalProperties = 0;
                var activeProperties = 0;
                alert("aaa");
                for (var i = 0; i < dataIds.length; i++) {

                    var rowData = grid.getRowData(dataIds[i]);
                    totalProperties += parseInt(rowData.propertyCount);
                    activeProperties += parseInt(rowData.activeCount);
                    alert(dataIds.length);
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
