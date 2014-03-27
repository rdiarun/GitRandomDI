<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.Technician.ViewModels.TechnicianDefaultAvailabilityViewModel>" %>
	<% using (Html.BeginForm("Delete", "TechnicianAvailability", FormMethod.Post, new { id = "delete-technician-availability-form" }))
   {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("TechnicianAvailability.RowVersion")%>
    <% } %>


    <% using (var form = Html.BeginForm("Index", "TechnicianAvailability", new { id= Model.Technician.Id}, FormMethod.Post, new { id = "edit-form" }))
    { %>           
        <%= Html.AntiForgeryToken() %>
        <%= Html.HiddenFor(model => model.Technician.RowVersion)%>        
        <%= Html.Hidden("Technician.State.Id", (Model.Technician.State!=null)?Model.Technician.State.Id.ToString():string.Empty)%>
    <div class="full">
        <div class="row">
            <%= Html.LabelFor(model=>Model.Technician.DefaultAvailability) %>
            <%= Html.CheckBoxList("AvailableDays", Model.Days, Model.AvailableDays.Select<DayOfWeek, string>(d => d.ToString("D")), new { @class = "checkbox-list available-days" })%>
        </div>
    </div>
    <div class="buttons">
        <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
        <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
        <%= Html.ActionButton("Cancel", "Index", "Home", null, new { @class = "button ui-corner-all ui-state-default " })%>
    </div>
    <div class="clear spacer"></div>
    <% } %>

        

    <table id="technician-availability-list"></table>
    <div id="technician-availability-pager"></div>
    <div class="clear spacer"></div>   
    <fieldset style="width: 881px;">
        <div class="widget technician-availability" id="technician-availability">
        </div>	                    
    </fieldset>                                    

   	
    <script type="text/javascript">

        var sGrid = $('#technician-availability-list');


        $().ready(function () {

            sGrid.jqGrid({
                url: '<%= Url.Action("GetItems", "TechnicianAvailability") %>',
                width: 905,
                height: 80,
                postData: { technicianId: '<%=Model.Technician.Id %>' },
                gridview: true,
                colNames: ['Id', 'RowVersion', 'Start Date', 'Start Time', 'End Date', 'End Time', 'Inclusion', '', ''],
                colModel: [
                    { name: 'id', index: 'Id', key: true, hidden: true, width: 40 },
                    { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                    { name: 'startDate', index: 'StartDate', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'startTime', index: 'StartTime', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'endDate', index: 'EndDate', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'endTime', index: 'EndTime', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'isInclusion', index: 'IsInclusion', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                    { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
                ],
                pager: '#technician-availability-pager',
                sortname: 'StartDate',
                sortorder: 'asc',
                ondblClickRow: function (id) {
                    editTechnicianAvailability(id);
                },
                loadComplete: function () {
                    var dataIds = sGrid.getDataIDs();

                    for (var i = 0; i < dataIds.length; i++) {
                        var rowData = sGrid.getRowData(dataIds[i]);

                        sGrid.setRowData(rowData.id, {
                            editLink: '<a href="#" onclick="editTechnicianAvailability(\'' + rowData.id + '\'); return false;" class="button-edit">Edit</a>',
                            deleteLink: '<a href="#" onclick="deleteTechnicianAvailability(\'' + rowData.id + '\', \'' + escape(rowData.startDate) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                        });

                    }
                }

            });

            sGrid.jqGrid('navGrid', '#technician-availability-pager', { search: false, edit: false, add: false, del: false });

            editTechnicianAvailability(0);

        });



        function editTechnicianAvailability(id) {
            $.ajax({
                type: 'GET',
                url: '<%= Url.Action("Edit", "TechnicianAvailability", new { id="_ID_", technicianId = Model.Technician.Id }) %>'.replace(/_ID_/g, id),
                success: function (result) {
                    loadTechnicianAvailability(result, id);
                }
            });
        }

        function loadTechnicianAvailability(result, id) {

            var editDialog = $('#technician-availability');
            editDialog.html(result);

            editDialog.dialog('option', 'buttons',
			{
			    'Cancel': function () {
			        $(this).dialog('close');
			    }
			});

            init('#technician-availability');
        }

        function saveTechnicianAvailability(id) {

            $.ajax({
                data: $('#edit-technician-availability-form :input').serialize(),
                url: '<%= Url.Action("Edit", "TechnicianAvailability", new { id="_ID_", technicianId = Model.Technician.Id }) %>'.replace(/_ID_/g, id),
                success: function (data) {
                    var editDialog = $('#technician-availability');
                    editDialog.html(data);
                    var isValid = $('#IsValid').val();
                    if (isValid != undefined) {
                        showInfoMessage("Success", "Technician Availability saved.");
                        reloadGrid(sGrid);
                        init('#technician-availability');
                    }
                    else {
                        init('#technician-availability');
                    }
                }
            });

        };



        function deleteTechnicianAvailability(id, name, rowVersion) {

            var deleteDialog = $('<div id="delete-technician-availability-dialog" style="display:none;" title="Delete Item"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you wish to delete &quot;' + unescape(name) + '&quot;. Continue?</p></div>');
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

			        var rowVersionHidden = $('#TechnicianAvailability_RowVersion')[0];

			        rowVersionHidden.value = rowVersion;

			        var form = $('#delete-technician-availability-form')[0];

			        form.action = '<%= Url.Action("Delete", "TechnicianAvailability", new { id="_ID_", technicianId = Model.Technician.Id }) %>'.replace(/_ID_/g, id);
			        form.submit();
			    }
			});

            deleteDialog.dialog('open');
        };
    </script>


