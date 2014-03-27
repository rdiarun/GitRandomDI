<%@ Page Title="Suburb Management" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>


<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<h2>Suburb Management</h2>

<table id="list"></table>
<div id="pager"></div>

<div class="buttons">
	 <%= Html.ActionButton("Add", "Edit", "Suburb", new { id = 0 }, new { @class = "button ui-corner-all ui-state-default" })%>		 
</div>

<% using (Html.BeginForm("Delete", "Suburb", FormMethod.Post, new { id = "delete-form" })) {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("RowVersion")%>
<% } %>

<script type="text/javascript">
    var grid = $('#list');

    $().ready(function() {
        grid.jqGrid({
        url: '<%= Url.Action("GetItems") %>',
                   
            colNames: ['Id', 'RowVersion', 'Name', 'Post Code', 'State', 'Zone', '', ''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: 0 },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 0 },
                { name: 'name', index: 'Name', hidden: false, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'postCode', index: 'PostCode', hidden: false, align: 'left', width: '60px', fixed: true, resizable: false, sortable: true, sorttype: 'text' },
                { name: 'state', index: 'State', hidden: false, align: 'left', width: '60px', fixed: true, resizable: false, sortable: true, sorttype: 'text' },
                { name: 'zone', index: 'Zone', hidden: false, align: 'left', width: '60px', fixed: true, resizable: false, sortable: true, sorttype: 'text' },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
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
                        deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                    });
                }
            },
            ondblClickRow: function(id) {
                goToSuburb(id);
            }
        })

        grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

        $('#dialog').dialog({
            height: 200,
            autoOpen: false
        });

    });

    function goToSuburb(id) {
        document.location.href = '<%= Url.Action("Edit") %>/' + id;
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

</script>

<div id="dialog" style="display:none;" title="Delete Item">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to delete the Suburb &quot;<span id="deleteTitle"></span>&quot;?</p>
</div>

   
</asp:Content>
