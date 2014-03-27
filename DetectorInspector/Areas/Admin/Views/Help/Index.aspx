<%@ Page Title="Help Management" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">

</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<h2>Help Management</h2>

<table id="list"></table>
<div id="pager"></div>

<div class="buttons">
	<%= Html.ActionButton("Add", "Edit", "Help", new { id = Guid.Empty }, new { @class = "button ui-corner-all ui-state-default" })%>		
</div>

<script type="text/javascript">
    var grid = $('#list');

    $().ready(function() {
        grid.jqGrid({
        url: '<%= Url.Action("GetItems") %>',
                    
            colNames: ['Id', 'RowVersion', 'Title',''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: 40 },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },              
                { name: 'title', index: 'Title', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#pager',
            sortname: 'Title',
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
                goToHelp(id);
            }
        })

        grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

    });

    function goToHelp(id) {
        document.location.href = '<%= Url.Action("Edit") %>/' + id;
    }
</script>

    
</asp:Content>


