<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.PropertyInfo.Id) + " Property: " + Model.PropertyInfo.ToString();
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%=Page.Title %></h2>
  	
    <div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
        <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Details", "View", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <% if (!Model.IsCreate())
                { %>          
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Contact Details", "Index", "Contact", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Bookings &amp; Service History</a></li>
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Landlord Details", "Landlord", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
			<li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Change Log", "Index", "ChangeLog", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>

            <%} %>
        </ul>
            
        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">            
            <% Html.RenderAction("Details", "Contact", new { area = "PropertyInfo", id= Model.PropertyInfo.Id }); %>
            <table id="list"></table>
            <div id="pager"></div>
            <div class="buttons">
                <% if (!Model.PropertyInfo.IsCancelled)
                   { %>
 	            <input type="button" class="button ui-corner-all ui-state-default" value="Add Booking" onclick="javascript: newBooking('<%= Model.PropertyInfo.Id %>');" />
                <input type="button" class="button ui-corner-all ui-state-default" value="Add Electrical Job" onclick="javascript: newElectricalJob('<%= Model.PropertyInfo.Id %>');" />
                <% } else { %>
                <span style="display: inline-block; color:red; margin-bottom: 10px;" >This property is cancelled, so bookings cannot be added.</span>
                <% } %>
            </div>
            <div class="clear spacer"></div>
            <% Html.RenderPartial("Detector"); %>

            <% using (Html.BeginForm("Delete", "Home", FormMethod.Post, new { id = "delete-form" }))
                {%>
                <%= Html.AntiForgeryToken()%>
                <%= Html.Hidden("RowVersion")%>
            <% } %>

            <script type="text/javascript">
                var grid = $('#list');

                $().ready(function () {
                    grid.jqGrid({
                        width: 871,
                        height: '0',
                        url: '<%= Url.Action("GetItems", "Home", new { area = "Booking" }) %>',
                        postData: { propertyInfoId: '<%=Model.PropertyInfo.Id %>' },
                        colNames: ['', 'RowVersion', 'Date', 'Key Number', 'Time', 'Key/Time', 'Notes', '', 'Problem', 'Electrician Required', 'Electrical Job','Completed','', '', '', ''],
                        colModel: [
                            { name: 'id', index: 'Id', key: true, hidden: true, width: 100 },
                            { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                            { name: 'bookingDate', index: 'Date', hidden: false, width: '95px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'keyNumber', index: 'KeyNumber', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'time', index: 'Time', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'keyTime', index: 'Time', hidden: false, width: '160px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'notes', index: 'Notes', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'hasServiceSheet', index: 'HasServiceSheet', hidden: true },
                            { name: 'hasProblem', index: 'HasProblem', hidden: false, width: '80px' },
                            { name: 'isElectricianRequired', index: 'IsElectricianRequired', hidden: false },
                            { name: 'isElectrical', index: 'IsElectrical', hidden: false, width: '110px' },
                            { name: 'isCompleted', index: 'IsCompleted', hidden: false, width: '90px' },
                            { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                            { name: 'serviceLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                            { name: 'electricalLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                            { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
                        ],
                        pager: '#pager',
                        sortname: 'Date',
                        sortorder: 'asc',
                        loadComplete: function () {
                            var dataIds = grid.getDataIDs();

                            for (var i = 0; i < dataIds.length; i++) {

                                var rowData = grid.getRowData(dataIds[i]);

                                grid.setRowData(rowData.id, {
                                    editLink: '<a href="#" onclick="openBooking(' + rowData.id + ' , \'<%=Model.PropertyInfo.Id %>\', false);return false;" class="button-edit">Edit</a>',
                                    serviceLink: '<a href="#" onclick="openBooking(' + rowData.id + ' , \'<%=Model.PropertyInfo.Id %>\', true);return false;" class="button-edit">Service</a>'
                                });

                                if (rowData.isElectricianRequired == 'true') {
                                    grid.setRowData(rowData.id, {
                                        electricalLink: '<a href="#" onclick="openBooking(' + rowData.id + ' , \'<%=Model.PropertyInfo.Id %>\', true);return false;" class="button-edit">Electrical</a>'
                                    });
                                }

                                if (rowData.hasServiceSheet == 'false') {
                                    grid.setRowData(rowData.id, {
                                        deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Cancel</a>'
                                    });
                                }
                            }
                            var rowCount = dataIds.length;

                            var height = (rowCount * 23) + 5;
                            grid.setGridHeight(height);

                        },
                        ondblClickRow: function (id) {
                            openBooking(id, '<%=Model.PropertyInfo.Id %>', false);
                        }
                    })

                    grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

                    $('#dialog').dialog({
                        modal: true,
                        autoOpen: false
                    });
                });


                function confirmDelete(id, name, rowVersion) {
                    $('#deleteTitle').text(unescape(name));
                    var deleteDialog = $('#dialog');
                    var slotGrid = $('#slot0_TotalServices');

                    var updateContactNotes = $('#UpdateContactNotes');
                    var rowData = slotGrid.getRowData(id);
                    updateContactNotes.val(rowData.contactNotes);
                    deleteDialog.dialog('option', 'buttons',
                    {
                        'No': function () {
                            $(this).dialog('close');
                        },
                        'Yes': function () {
                            var updateContactNotes = $('#UpdateContactNotes').val();
                            var inspectionStatus = $('input[name=BulkInspectionStatus]:checked').val();
                            $.ajax({
                                url: '<%= Url.Action("Cancel", "Home", new { area = "Booking", id="_ID_"}) %>/'.replace(/_ID_/g, escape(id)),
                                dataType: 'json',
                                data: { InspectionStatus: inspectionStatus, ContactNotes: updateContactNotes, RowVersion: rowVersion },
                                success: function (result) {
                                    if (result.success != true) {
                                        showErrorMessage('Booking not cancelled', result.message);
                                    }
                                    else {
                                        slotGrid.setCell(id, 'contactNotes', updateContactNotes, null, '');
                                        refreshGrid();
                                        showInfoMessage('Booking cancelled', result.message);
                                    }

                                }
                            });
                            $(this).dialog('close');
                        }
                    });

                    deleteDialog.dialog('open');
                }



                function refreshGrid() {
                    var grid = $('#list');
                    reloadGrid(grid);
                }



            </script>

        <div id="dialog" style="display:none;" title="Cancel Booking">
	        <p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to cancel the booking? If so, please provide the following:</p>
            <div id="BulkInspectionStatusContainer" class="row">
                <label for="InspectionStatus">New Inspection Status</label>
                <div class="clear"></div>
	            <%= Html.RadioButtonList("BulkInspectionStatus", Model.UpdateInspectionStatuses, string.Empty, new { @class="radiobutton-list bulk-action", style="width: 280px; display: block;"})%>
            </div>   
            <div id="contact-notes" class="row">
                <label>Contact Notes</label>
                <%= Html.TextArea("UpdateContactNotes", new { style = "width: 100%;height: 100px;" })%>
            </div>
        </div>

        </div>
    </div>

</asp:Content>


