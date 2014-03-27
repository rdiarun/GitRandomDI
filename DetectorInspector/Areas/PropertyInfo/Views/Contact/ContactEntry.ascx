<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>
    <% using (Html.BeginForm("Delete", "Contact", FormMethod.Post, new { id = "delete-tenant-contact-form" }))
   {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("ContactEntry.RowVersion")%>
    <% } %>
    <table id="tenant-contact-list"></table>
    <div id="tenant-contact-pager"></div>
    <div class="clear spacer"></div>   
    <fieldset style="width: 377px;">
        <div class="widget tenant-contact" id="tenant-contact">
        </div>	                    
    </fieldset>               	
    <script type="text/javascript">

        var sGrid = $('#tenant-contact-list');


        $().ready(function () {

            sGrid.jqGrid({
                url: '<%= Url.Action("GetItems", "Contact") %>',
                width: 400,
                height: 80,
                postData: { propertyInfoId: '<%=Model.PropertyInfo.Id %>' },
                gridview: true,
                colNames: ['Id', 'RowVersion', 'Number', 'Type','', ''],
                colModel: [
                    { name: 'id', index: 'Id', key: true, hidden: true, width: 40 },
                    { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                    { name: 'contactNumber', index: 'ContactNumber', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'contactNumberType', index: 'ContactNumberType.Name', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                    { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
                ],
                pager: '#tenant-contact-pager',
                sortname: 'ContactNumber',
                sortorder: 'asc',
                ondblClickRow: function (id) {
                    editTenantContact(id);
                },
                loadComplete: function () {
                    var dataIds = sGrid.getDataIDs();

                    for (var i = 0; i < dataIds.length; i++) {
                        var rowData = sGrid.getRowData(dataIds[i]);

                        sGrid.setRowData(rowData.id, {
                            editLink: '<a href="#" onclick="editTenantContact(\'' + rowData.id + '\'); return false;" class="button-edit">Edit</a>',
                            deleteLink: '<a href="#" onclick="deleteTenantContact(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                        });

                    }
                }

            });

            sGrid.jqGrid('navGrid', '#tenant-contact-pager', { search: false, edit: false, add: false, del: false });

            editTenantContact(0);

        });



        function editTenantContact(id) {
            $.ajax({
                type: 'GET',
                url: '<%= Url.Action("Edit", "Contact", new { id="_ID_", propertyInfoId = Model.PropertyInfo.Id }) %>'.replace(/_ID_/g, id),
                success: function (result) {
                    loadTenantContact(result, id);
                }
            });
        }

        function loadTenantContact(result, id) {

            var editDialog = $('#tenant-contact');
            editDialog.html(result);

            editDialog.dialog('option', 'buttons',
			{
			    'Cancel': function () {
			        $(this).dialog('close');
			    }
			});

			init('#tenant-contact');
        }

        function saveTenantContact(id) {

            $.ajax({
                data: $('#edit-tenant-contact-form :input').serialize(),
                url: '<%= Url.Action("Edit", "Contact", new { id="_ID_", propertyInfoId = Model.PropertyInfo.Id }) %>'.replace(/_ID_/g, id),
                success: function (data) {
                    var editDialog = $('#tenant-contact');
                    editDialog.html(data);
                    var isValid = $('#IsValid').val();
                    if (isValid != undefined) {
                        showInfoMessage("Success", "Contact Entry saved.");
                        var sGrid = $('#tenant-contact-list');
                        reloadGrid(sGrid);
                        init('#tenant-contact');
                    }
                    else {
                        init('#tenant-contact');
                    }
                }
            });

        };



        function deleteTenantContact(id, name, rowVersion) {

            var deleteDialog = $('<div id="delete-tenant-contact-dialog" style="display:none;" title="Delete Item"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you wish to delete entry - Continue?</p></div>');
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

			        var rowVersionHidden = $('#ContactEntry_RowVersion')[0];

			        rowVersionHidden.value = rowVersion;

			        var form = $('#delete-tenant-contact-form')[0];

			        $.ajax({
			            data: $('#delete-tenant-contact-form :input').serialize(),
			            url: '<%= Url.Action("Delete", "Contact", new { id="_ID_", propertyInfoId = Model.PropertyInfo.Id }) %>'.replace(/_ID_/g, id),
			            success: function (data) {

			                showInfoMessage("Success", "Contact Info deleted.");
			                var sGrid = $('#tenant-contact-list');
			                reloadGrid(sGrid);

			            }
			        });

			    }
			});

            deleteDialog.dialog('open');
        };
    </script>


