<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.Agency.ViewModels.AgencyViewModel>" %>
	<% using (Html.BeginForm("Delete", "PropertyManager", FormMethod.Post, new { id = "delete-property-manager-form" }))
   {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("PropertyManager.RowVersion")%>
    <% } %>


    <table id="property-manager-list"></table>
    <div id="property-manager-pager"></div>
    <div class="buttons">
	    <input type="button" class="button ui-corner-all ui-state-default" style="margin-right: 7px;" value="Add" onclick="javascript: editPropertyManager(0);" />
    </div>
    <div class="clear spacer"></div>   
    <fieldset style="width: 881px">
        <div class="widget property-manager" id="property-manager">
        </div>	                    
    </fieldset>                                    
       	
    <script type="text/javascript">

        var sGrid = $('#property-manager-list');


        $().ready(function () {

            sGrid.jqGrid({
                url: '<%= Url.Action("GetItems", "PropertyManager") %>',
                width: 905,
                height: 80,
                postData: { agencyId: '<%=Model.Agency.Id %>' },
                gridview: true,
                colNames: ['Id', 'RowVersion', 'Name', 'Position', 'Telephone', 'Email', '', ''],
                colModel: [
                    { name: 'id', index: 'Id', key: true, hidden: true, width: 40 },
                    { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                    { name: 'name', index: 'Name', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'position', index: 'Position', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'telephone', index: 'Telephone', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'email', index: 'Email', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                    { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
                ],
                pager: '#property-manager-pager',
                sortname: 'Name',
                sortorder: 'asc',
                ondblClickRow: function (id) {
                    editPropertyManager(id);
                },
                loadComplete: function () {
                    var dataIds = sGrid.getDataIDs();

                    for (var i = 0; i < dataIds.length; i++) {
                        var rowData = sGrid.getRowData(dataIds[i]);

                        sGrid.setRowData(rowData.id, {
                            editLink: '<a href="#" onclick="editPropertyManager(\'' + rowData.id + '\'); return false;" class="button-edit">Edit</a>',
                            deleteLink: '<a href="#" onclick="deletePropertyManager(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                        });

                    }
                }

            });

            sGrid.jqGrid('navGrid', '#property-manager-pager', { search: false, edit: false, add: false, del: false });

            editPropertyManager(0);

        });



        function editPropertyManager(id) {
            $.ajax({
                type: 'GET',
                url: '<%= Url.Action("Edit", "PropertyManager", new { id="_ID_", agencyId = Model.Agency.Id }) %>'.replace(/_ID_/g, id),
                success: function (result) {
                    loadPropertyManager(result, id);
                }
            });
        }

        function loadPropertyManager(result, id) {

            var editDialog = $('#property-manager');
            editDialog.html(result);

            editDialog.dialog('option', 'buttons',
			{
			    'Cancel': function () {
			        $(this).dialog('close');
			    }
			});

            init('#property-manager');
        }

        function savePropertyManager(id) {
            $.ajax({
                data: $('#edit-property-manager-form :input').serialize(),
                url: '<%= Url.Action("Edit", "PropertyManager", new { id="_ID_", agencyId = Model.Agency.Id }) %>'.replace(/_ID_/g, id),
                success: function (data) {
                    var editDialog = $('#property-manager');
                    editDialog.html(data);
                    var isValid = $('#IsValid').val();
                    if (isValid != undefined) {
                        showInfoMessage("Success", "Property Manager saved.");
                        reloadGrid(sGrid);
                        init('#property-manager');
                    }
                    else {
                        init('#property-manager');
                    }
                }
            });

        };



        function deletePropertyManager(id, name, rowVersion) {
            var deleteDialog = $('<div id="delete-property-manager-dialog" style="display:none;" title="Delete Item"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you wish to delete &quot;' + unescape(name) + '&quot;. Continue?</p></div>');
            deleteDialog.dialog({
                height: 230
            });
            deleteDialog.dialog('option', 'buttons',
			{
			    'No': function () {
			        $(this).dialog('close');
			    },
			    'Yes': function () {
			        
			        $(this).dialog('close');

			        var rowVersionHidden = $('#PropertyManager_RowVersion')[0];
			        rowVersionHidden.value = rowVersion;

			        var form = $('#delete-property-manager-form')[0];

			        form.action = '<%= Url.Action("Delete", "PropertyManager", new { id="_ID_", agencyId = Model.Agency.Id }) %>'.replace(/_ID_/g, id);
			        form.submit();
			    }
			});

            deleteDialog.dialog('open');
        };
    </script>


