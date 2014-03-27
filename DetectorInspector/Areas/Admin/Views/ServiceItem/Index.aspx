<%@ Page Title="ServiceItem Management" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>


<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<h2>Service Item Management</h2>

<table id="list"></table>
<div id="pager"></div>

<div class="buttons">
	 <%= Html.ActionButton("Add", "Edit", "ServiceItem", new { id = 0 }, new { @class = "button ui-corner-all ui-state-default" })%>		 
</div>

<script type="text/javascript">
	var grid = $('#list');

	$().ready(function() {
		grid.jqGrid({
		url: '<%= Url.Action("GetItems") %>',
				   
			colNames: ['Id', 'RowVersion', 'Name', 'Code', 'Price', ''],
			colModel: [
				{ name: 'id', index: 'Id', key: true, hidden: true, width: 0 },
				{ name: 'rowVersion', index: 'RowVersion', hidden: true, width: 0 },
				{ name: 'name', index: 'Name', hidden: false, align: 'left', sortable: true, sorttype: 'text' },
				{ name: 'code', index: 'Code', hidden: false, align: 'left', sortable: true, sorttype: 'text' },
				{ name: 'price', index: 'Price', hidden: false, align: 'right', width: '60px', fixed: true, resizable: false, sortable: true, sorttype: 'text' },
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
				goToServiceItem(id);
			}
		})

		grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

		$('#dialog').dialog({
			height: 200,
			autoOpen: false
		});

	});

	function goToServiceItem(id) {
		document.location.href = '<%= Url.Action("Edit") %>/' + id;
	}

</script>
   
</asp:Content>
