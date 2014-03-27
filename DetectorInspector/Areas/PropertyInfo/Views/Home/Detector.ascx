<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>
	<% using (Html.BeginForm("Delete", "Detector", FormMethod.Post, new { id = "delete-detector-form" }))
   {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("Detector.RowVersion")%>
    <% } %>

    <table id="detector-list"></table>
    <div id="detector-pager"></div>
    <%--<fieldset style="width: 849px;">
        <div class="widget detector" id="detector">
        </div>	                    
    </fieldset>--%>                                    
   	
    <script type="text/javascript">

        var sGrid = $('#detector-list');


        $().ready(function () {

            sGrid.jqGrid({
                url: '<%= Url.Action("GetDetectorItems", "Home") %>',
                width: 871,
                height: '0',
                postData: { propertyInfoId: '<%=Model.PropertyInfo.Id %>' },
                gridview: true,
                colNames: ['Id', 'RowVersion', 'Detector Type', 'Expiry Year', 'Not Required', 'Location', 'Manufacturer', '', ''],
                colModel: [
                    { name: 'id', index: 'Id', key: true, hidden: true, width: 40 },
                    { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                    { name: 'detectorType', index: 'DetectorType.Name', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'expiryYear', index: 'ExpiryYear', hidden: false, width: '50px', align: 'right', sortable: true, sorttype: 'integer' },
                    { name: 'isOptional', index: 'IsOptional', hidden: false, width: '50px', align: 'right', sortable: true, sorttype: 'text' },
                    { name: 'location', index: 'Location', hidden: false, width: 100, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'manufacturer', index: 'Manufacturer', hidden: false, width: 100, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'editLink', width: '40px', hidden: true, fixed: true, resizable: false, align: 'center', sortable: false },
                    { name: 'deleteLink', width: '55px', hidden: true, fixed: true, resizable: false, align: 'center', sortable: false }
                ],
                pager: '#detector-pager',
                sortname: 'ExpiryYear',
                sortorder: 'asc',
                ondblClickRow: function (id) {
                    //editDetector(id);
                },
                loadComplete: function () {
                    var dataIds = sGrid.getDataIDs();

                    for (var i = 0; i < dataIds.length; i++) {
                        var rowData = sGrid.getRowData(dataIds[i]);

                        sGrid.setRowData(rowData.id, {
                            editLink: '<a href="#" onclick="editDetector(\'' + rowData.id + '\'); return false;" class="button-edit">Edit</a>',
                            deleteLink: '<a href="#" onclick="deleteDetector(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                        });

                    }
                    var rowCount = dataIds.length;

                    var height = (rowCount * 23) + 5;
                    sGrid.setGridHeight(height);

                }

            });

            sGrid.jqGrid('navGrid', '#detector-pager', { search: false, edit: false, add: false, del: false });

            //editDetector(0);

        });



        function editDetector(id) {
            $.ajax({
                type: 'GET',
                url: '<%= Url.Action("EditDetector", "Home", new { id="_ID_", propertyInfoId = Model.PropertyInfo.Id }) %>'.replace(/_ID_/g, id),
                success: function (result) {
                    loadDetector(result, id);
                }
            });
        }

        function loadDetector(result, id) {

            var editDialog = $('#detector');
            editDialog.html(result);

            editDialog.dialog('option', 'buttons',
			{
			    'Cancel': function () {
			        $(this).dialog('close');
			    }
			});

            init('#detector');
        }

        function saveDetector(id) {
            $.ajax({
                data: $('#edit-detector-form :input').serialize(),
                url: '<%= Url.Action("EditDetector", "Home", new { id="_ID_", propertyInfoId = Model.PropertyInfo.Id }) %>'.replace(/_ID_/g, id),
                success: function (data) {
                    var editDialog = $('#detector');
                    editDialog.html(data);
                    
                    var isValid = $('#IsValid').val();
                    if (isValid != undefined) {
                        showInfoMessage("Success", "Detector saved.");
                        var sGrid = $('#detector-list');
                        reloadGrid(sGrid);
                        init('#detector');
                    }
                    else {
                        init('#detector');
                    }
                }
            });

        };



        function deleteDetector(id, name, rowVersion) {

            var deleteDialog = $('<div id="delete-detector-dialog" style="display:none;" title="Delete Item"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you wish to delete &quot;' + unescape(name) + '&quot;. Continue?</p></div>');
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

                    var rowVersionHidden = $('#Detector_RowVersion')[0];
                    rowVersionHidden.value = rowVersion;

                    $.ajax({
                        data: $('#delete-detector-form :input').serialize(),
                        url: '<%= Url.Action("DeleteDetector", "Home", new { id="_ID_", propertyInfoId = Model.PropertyInfo.Id }) %>'.replace(/_ID_/g, id),
                        success: function (data) {

                            showInfoMessage("Success", "Detector deleted.");
                            var sGrid = $('#detector-list');
                            reloadGrid(sGrid);

                        }
                    });

			    }
			});

            deleteDialog.dialog('open');
        };
    </script>


