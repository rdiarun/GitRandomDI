<%@ Page Title="Notification Management" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

<h2>Notification Management</h2>
<table id="list"></table>
<div id="pager"></div>

<script type="text/javascript">
    var grid = $('#list');

    $().ready(function() {
        grid.jqGrid({
        url: '<%= Url.Action("GetItems") %>',
       
            colNames: ['Id', 'Name',''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: 40 },
                { name: 'name', index: 'Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#pager',
            sortname: 'Name',
            sortorder: 'asc',
            loadComplete: function() {
                var dataIds = grid.getDataIDs();

                for (var i = 0; i < dataIds.length; i++) {

                    var rowData = grid.getRowData(dataIds[i]);

                    grid.setRowData(rowData.id, {
                        editLink: '<a href="<%= Url.Action("Edit") %>/' + rowData.id + '" class="button-edit">Edit</a>'
                    });
                }
            },
            ondblClickRow: function(id) {
                goToNotification(id);
            }
        })

        grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

        $('#dialog').dialog({
            height: 200,
            autoOpen: false
        });

    });

    function goToNotification(id) {
        document.location.href = '<%= Url.Action("Edit") %>/' + id;
    }
</script>


</asp:Content>


