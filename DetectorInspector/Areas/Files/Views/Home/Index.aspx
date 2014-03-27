<%@ Page Title="Edit Upload" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>


<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	<h2>Edit Upload</span></h2>
		
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form") %>

	<% using (Html.BeginForm("Delete", "Home", FormMethod.Post, new { id = "delete-form" })) {%>
		<%= Html.AntiForgeryToken()%>
		<%= Html.Hidden("RowVersion")%>
	<% } %>
	
				
		<table id="list"></table>
		<div id="pager"></div>
		
		<div class="buttons">
            <input type="button" onclick="addAttachment()" class="button ui-corner-all ui-state-default" value="Add" />
        </div>
		

		<div id="delete-dialog" style="display:none;" title="Delete Item">
			<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to delete the attachment &quot;<span id="deleteTitle"></span>&quot;?</p>
		</div>	
		
		
<script type="text/javascript">
	var grid = $('#list');
	
    $().ready(function() {

        grid.jqGrid({
            url: '<%= Url.Action("GetItems") %>',           
            colNames: ['Id', 'RowVersion', 'Name','', '', ''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: 40, sortable: false },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40, sortable: false },
                { name: 'name', index: 'Name', sortable: true },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'deleteLink', width: '55px', fixed: true, hidden: false, resizable: false, align: 'center', sortable: false },
                { name: 'downloadLink', width: '85px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#pager',
            sortname: 'Name',
            sortorder: 'asc',
            loadComplete: function() {
                var dataIds = grid.getDataIDs();

                for (var i = 0; i < dataIds.length; i++) {
                    var rowData = grid.getRowData(dataIds[i]);

                    grid.setRowData(rowData.id, {
                        editLink: '<a href="#" onclick="editAttachment(\'' + rowData.id + '\'); return false;" class="button-edit">Edit</a>',
                        deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>',
                        downloadLink: '<a href="<%= Url.Action("Download") %>/' + rowData.id + '" class="button-download">Download</a>'
                    });
                }
            },
            ondblClickRow: function(id) {
                editAttachment(id);
            }
        })

        grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });


        $('#delete-dialog').dialog({
            height: 200,
            autoOpen: false
        });
    });


    function addAttachment(id) {

        loadDialog({ url: '<%= Url.Action("Edit") %>',
        buttonType: 'edit'
        
        });
    }

  
    function editAttachment(id) {
        
         loadDialog({ url: '<%= Url.Action("Edit", "Home", new { id="_ID_"}) %>'.replace(/_ID_/g, id),
            buttonType: 'edit'
        
        });             
    }

    function closeFileDialog() {
        var dialog = $('#dialog');
       
        dialog.dialog('close');
    
    	reloadGrid(grid);
    }
  
    function confirmDelete(id, name, rowVersion) {

        $('#deleteTitle').text(unescape(name));

        var deleteDialog = $('#delete-dialog');

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

			        form.action = '<%= Url.Action("Delete", new { id="_ID_" }) %>'.replace(/_ID_/g, id);
			        form.submit();
			    }
			});

        deleteDialog.dialog('open');
    }

</script>
</asp:Content>
