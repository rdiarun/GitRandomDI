<%@ Page Title="Property Management" Language="C#" MasterPageFile="~/Views/Shared/WideScreen.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoSearchViewModel>" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <%-- <meta http-equiv="refresh" content="5;url="" />--%>
    <% if (TempData.ContainsKey("DialogValue"))
       { 
    %>
    <input type="hidden" id="dialog-value" name="dialog-value" value="<%=TempData["DialogValue"] %>" /><% 
           TempData.Remove("DialogValue");
       }
       if (TempData.ContainsKey("CloseDialog"))
       { 
    %><input type="hidden" id="close-dialog" name="close-dialog" value="<%=TempData["CloseDialog"] %>" /><% 
           TempData.Remove("CloseDialog");
    %>
    <script type="text/javascript">

        $().ready(function () {

            var dialogValue = $('#dialog-value').val();
            var isClosed = $('#close-dialog').val();

            if (window.opener) {

                if (window.opener.search) {
                    window.opener.search();
                } else if (window.opener.reloadGrid) {
                    var refreshGrid = window.opener.$('#' + dialogValue + '-list');
                    if (refreshGrid.length > 0)
                        window.opener.reloadGrid(refreshGrid);
                }
            }

            if (isClosed == 'true') {
                window.close();
            }

        });

    </script>

    <%
			
       }
       else
       {
    %>

    <%= Session["Message"]  %>

    <fieldset style="width: 482px; display: inline-block; float: left; height: 320px;">
        <legend>Property Search</legend>

        <div class="row">
            <label for="AgencyId" style="width: 95px;">Agency</label>
            <%= Html.DropDownList("AgencyId", Model.Agencies, "-- All --", new { style = "width: 130px; margin-right: 10px;", onChange="agencyChanged();" })%>
        </div>
        <div class="row">
            <label for="PropertyManagerId" style="width: 95px;">Property Manager</label>
            <%= Html.DropDownList("PropertyManagerId", Model.PropertyManagers, "-- All --", new { style="width: 130px; margin-right: 10px; " })%>
        </div>
        <div class="row">
            <label for="Keyword" style="width: 95px;">Keyword</label>
            <%= Html.TextBoxFor(m => m.Keyword, new { style = "width: 124px; margin-right: 10px;", @class = "textbox" })%>
        </div>
        <div class="row">
            <label for="StartDate" style="width: 95px;">Service Due From</label>
            <%= Html.TextBox("StartDate", StringFormatter.LocalDate(Model.StartDate), new { @class = "datepicker textbox", style = "width: 124px;margin-right: 10px; " })%>
            <label for="EndDate" style="width: 25px;">To</label>
            <%= Html.TextBox("EndDate", StringFormatter.LocalDate(Model.EndDate), new { @class = "datepicker textbox", style = "width: 124px;margin-right: 10px;" })%>
        </div>
        <div class="row" style="display: none">
            <label for="Cancelled" style="width: 95px;">Cancelled</label>
            <%= Html.DropDownList("Cancelled", Model.CancelledSelectList, new { style="width: 130px;"})%>
        </div>
        <div class="row">
            <label for="HasProblem" style="width: 95px;">Has Problem</label>
            <%= Html.DropDownList("HasProblem", Model.ProblemSelectList, new { style="width: 130px;"})%>
            <span id="extra_hasProblem"></span>
        </div>
    </fieldset>
    <fieldset style="width: 482px; display: inline-block; float: left; margin-left: 10px; height: 320px;">
        <legend>Inspection Status</legend>
        <div class="row property-search">
            <div class="clear"></div>
            <span class="checkbox-list InspectionGroups">
                <span>
                    <input type="checkbox" id="Inspection.CheckAll" onclick="javascript: if (!this.checked) { checkAll('InspectionStatuses', 'InspectionGroups,inspection-due', this.checked); } else { checkAll('InspectionStatuses', 'InspectionGroups,inspection-due', this.checked); checkAll('ElectricalWorkStatuses', 'ElectricalGroups', !this.checked); }" />
                    <label for="Inspection.CheckAll" style="font-weight: bold;">Check All</label>
                </span>
            </span>
            <div class="clear spacer"></div>
            <div class="clear spacer"></div>
            <span class="checkbox-list InspectionGroups">
                <span>
                    <input type="checkbox" id="Inspection_DueForService" name="Inspection_DueForService" checked="checked" onclick="javascript: if (!this.checked) { checkAll(null, 'inspection-due', this.checked); } else { checkAll(null, 'inspection-due', this.checked); checkAll('ElectricalWorkStatuses', 'ElectricalGroups', !this.checked); }" />
                    <label for="Inspection.DueForService" style="font-weight: bold;">Due for Service</label>
                </span>
            </span>
            <div class="clear"></div>
            <span class="checkbox-list inspection-due">
                <span>
                    <input style="margin-right: 0px" checked="checked" id="InspectionStatuses_IsComingUpForService" name="InspectionStatuses_IsComingUpForService" type="checkbox" onclick="javascript: checkAll('ElectricalWorkStatuses', 'ElectricalGroups', false);">
                    <label for="InspectionStatuses_IsComingUpForService" style="background-color: #64E986; border: 1px solid #CCCCCC; width: 140px; margin-right: 70px;">Coming Up For Service<span id="extra_InspectionStatuses_ComingUpForService"></span></label>
                </span>
                <span>
                    <input checked="true" id="InspectionStatuses_IsNew" name="InspectionStatuses_IsNew" type="checkbox" onclick="javascript: checkAll('ElectricalWorkStatuses', 'ElectricalGroups', false);"><label for="InspectionStatuses_IsNew" style="background-color: #f6d697; border: 1px solid #CCCCCC; width: 120px; margin-right: 90px;">New Property<span id="extra_InspectionStatuses_new"></span></label>
                </span>
                <span>
                    <input checked="true" id="InspectionStatuses_IsOverDue" name="InspectionStatuses_IsOverDue" type="checkbox" onclick="javascript: checkAll('ElectricalWorkStatuses', 'ElectricalGroups', false);"><label for="InspectionStatuses_IsOverDue" style="background-color: #d67b7b; border: 1px solid #CCCCCC; width: 120px; margin-right: 90px;">Overdue<span id="extra_InspectionStatuses_overdue"></span></label>
                </span>
            </span>

            <%= Html.CheckBoxList("InspectionStatuses", Model.DueForServiceInspectionStatuses, Model.SelectedInspectionStatuses, new { @class = "checkbox-list inspection-due", onClick = "javascript:checkAll('ElectricalWorkStatuses','ElectricalGroups',false);" })%>
            <div class="clear spacer"></div>
            <div class="clear spacer"></div>
            <span class="checkbox-list InspectionGroups">
                <span>
                    <input type="checkbox" id="Inspection.OnHold" name="Inspection_OnHold" onclick="javascript: if (!this.checked) { checkAll(null, 'inspection-onhold', this.checked); } else { checkAll(null, 'inspection-onhold', this.checked); checkAll('ElectricalWorkStatuses', 'ElectricalGroups', !this.checked); }" />
                    <label for="Inspection.OnHold" style="font-weight: bold;">Property On Hold</label>
                </span>
            </span>
            <div class="clear"></div>
            <%= Html.CheckBoxList("InspectionStatuses", Model.OnHoldInspectionStatuses, Model.SelectedInspectionStatuses, new { @class = "checkbox-list inspection-onhold", onClick = "javascript:checkAll('ElectricalWorkStatuses','ElectricalGroups',false);" })%>
            <div class="clear spacer"></div>
            <div class="clear spacer"></div>
            <span class="checkbox-list InspectionGroups">
                <span>
                    <input type="checkbox" id="Inspection.Booked" name="Inspection_Booked" onclick="javascript: if (!this.checked) { checkAll(null, 'inspection-booked', this.checked); } else { checkAll(null, 'inspection-booked', this.checked); checkAll('ElectricalWorkStatuses', 'ElectricalGroups', !this.checked); }" />
                    <label for="Inspection.Booked" style="font-weight: bold;">Booked</label>
                </span>
            </span>
            <div class="clear"></div>
            <%= Html.CheckBoxList("InspectionStatuses", Model.BookedInspectionStatuses, Model.SelectedInspectionStatuses, new { @class = "checkbox-list inspection-booked", onClick = "javascript:checkAll('ElectricalWorkStatuses','ElectricalGroups',false);" })%>
            <div class="clear spacer"></div>
            <div class="clear spacer"></div>
            <span class="checkbox-list InspectionGroups">
                <span>
                    <input type="checkbox" id="Inspection.Completed" name="Inspection_Completed" onclick="javascript: if (!this.checked) { checkAll(null, 'inspection-completed', this.checked); } else { checkAll(null, 'inspection-completed', this.checked); checkAll('ElectricalWorkStatuses', 'ElectricalGroups', !this.checked); }" />
                    <label for="Inspection.Completed" style="font-weight: bold;">Completed</label>
                </span>
            </span>
            <div class="clear"></div>
            <%= Html.CheckBoxList("InspectionStatuses", Model.CompletedInspectionStatuses, Model.SelectedInspectionStatuses, new { @class = "checkbox-list inspection-completed", onClick = "javascript:checkAll('ElectricalWorkStatuses','ElectricalGroups',false);" })%>
        </div>
        <div style="padding-top: 8px;">
            <input type="button" onclick="showInspectionBulkAction();" value="Bulk Action" class="button ui-corner-all ui-state-default" />
        </div>

    </fieldset>
    <fieldset style="width: 482px; display: inline-block; float: left; margin-left: 10px; height: 320px;">
        <legend>Electrical Work Status</legend>
        <div class="row property-search">
            <span class="checkbox-list ElectricalGroups">
                <span>
                    <input type="checkbox" id="ElectricalWork.CheckAll" onclick="javascript: if (!this.checked) { checkAll('ElectricalWorkStatuses', 'ElectricalGroups,electricalwork-send', this.checked); } else { checkAll('ElectricalWorkStatuses', 'ElectricalGroups,electricalwork-send', this.checked); checkAll('InspectionStatuses', 'InspectionGroups,inspection-due', !this.checked); }" />
                    <label for="ElectricalWork.CheckAll" style="font-weight: bold;">Check All</label>
                </span>
            </span>
            <div class="clear spacer"></div>
            <div class="clear spacer"></div>
            <span class="checkbox-list ElectricalGroups">
                <span>
                    <input type="checkbox" id="ElectricalWork.Send" name="ElectricalWork_Send" onclick="javascript: if (!this.checked) { checkAll(null, 'electricalwork-send', this.checked); } else { checkAll(null, 'electricalwork-send', this.checked); checkAll('InspectionStatuses', 'InspectionGroups,inspection-due', !this.checked); }" />
                    <label for="ElectricalWork.Send" style="font-weight: bold;">Send for Electrical Approval</label>
                </span>
            </span>
            <div class="clear"></div>
            <%= Html.CheckBoxList("ElectricalWorkStatuses", Model.SendForElectricalApprovalStatuses, Model.SelectedElectricalWorkStatuses, new { @class = "checkbox-list electricalwork-send", onClick = "javascript:checkAll('InspectionStatuses','InspectionGroups,inspection-due',false);" })%>
            <span class="checkbox-list ElectricalGroups electricalwork-send">
                <span>
                    <input id="ElectricalWorkStatuses_IsOverDue" name="ElectricalWorkStatuses_IsOverDue" type="checkbox" onclick="javascript: checkAll('InspectionStatuses', 'InspectionGroups,inspection-due', false);"><label for="ElectricalWorkStatuses_IsOverDue" style="background-color: #d67b7b; border: 1px solid #CCCCCC; width: 200px; margin-right: 10px;">Electrician Required (Automatic)<span id="extra_ElectricalWorkStatuses_overdue"></span></label>
                </span>
            </span>
            <div class="clear spacer"></div>
            <div class="clear spacer"></div>
            <span class="checkbox-list ElectricalGroups">
                <span>
                    <input type="checkbox" id="ElectricalWork.Awaiting" name="ElectricalWork_Awaiting" onclick="javascript: if (!this.checked) { checkAll(null, 'electricalwork-awaiting', this.checked); } else { checkAll(null, 'electricalwork-awaiting', this.checked); checkAll('InspectionStatuses', 'InspectionGroups,inspection-due', !this.checked); }" />
                    <label for="ElectricalWork.Awaiting" style="font-weight: bold;">Awaiting Electrical Approval</label>
                </span>
            </span>
            <div class="clear"></div>
            <%= Html.CheckBoxList("ElectricalWorkStatuses", Model.AwaitingElectricalApprovalStatuses, Model.SelectedElectricalWorkStatuses, new { @class = "checkbox-list electricalwork-awaiting", onClick = "javascript:checkAll('InspectionStatuses','InspectionGroups,inspection-due',false);" })%>
            <div class="clear spacer"></div>
            <div class="clear spacer"></div>
            <span class="checkbox-list ElectricalGroups">
                <span>
                    <input type="checkbox" id="ElectricalWork.Accepted" name="ElectricalWork_Accepted" onclick="javascript: if (!this.checked) { checkAll(null, 'electricalwork-accepted', this.checked); } else { checkAll(null, 'electricalwork-accepted', this.checked); checkAll('InspectionStatuses', 'InspectionGroups,inspection-due', !this.checked); }" />
                    <label for="ElectricalWork.Accepted" style="font-weight: bold;">Electrical Approval Accepted</label>
                </span>
            </span>
            <div class="clear"></div>
            <%= Html.CheckBoxList("ElectricalWorkStatuses", Model.ElectricalApprovalAcceptedStatuses, Model.SelectedElectricalWorkStatuses, new { @class = "checkbox-list electricalwork-accepted", onClick = "javascript:checkAll('InspectionStatuses','InspectionGroups,inspection-due',false);" })%>
        </div>

        <div>
            <input type="button" onclick="showElectricalWorkBulkAction();" value="Bulk Action" class="button ui-corner-all ui-state-default" />
        </div>
    </fieldset>
    <div class="clear"></div>

    <div class="left">
        <div class="row">
            <input type="checkbox" name="Check_All" id="Check.All" onclick="javascript: checkAll('selectedRow', null, this.checked); var count = getPropertyCount(); updatePropertyCounter(count);" style="padding-bottom: 0px; margin-left: 15px;" />
            <label for="Check.All">Check All Properties (<span id="property-count">0</span> selected)</label>
        </div>
    </div>
    <div class="right">
        <div class="row" style="float: right;">
            <input type="button" class="button ui-corner-all ui-state-default" value="Add" onclick="javascript: newPropertyInfo();" />
            <input type="button" onclick="search();" value="Search" class="button ui-corner-all ui-state-default" />
            <input type="button" onclick="clearSearch();" value="Clear" class="button ui-corner-all ui-state-default" />
            <!-- rjc added button to update the totals -->
            <input type="button" onclick="getStatusCounters();" value="Update All Totals" class="button ui-corner-all ui-state-default" />

        </div>
    </div>
    <div class="clear spacer"></div>

    <table id="property-search-list"></table>
    <div id="pager"></div>

    <% using (Html.BeginForm("PerformBulkAction", "Home", FormMethod.Post, new { id = "bulk-form", enctype = "multipart/form-data" }))
       {%>
    <%= Html.Hidden("bulkAction")%>
    <%= Html.Hidden("electricalWorkStatus")%>
    <%= Html.Hidden("inspectionStatus")%>
    <%= Html.Hidden("notificationDate")%>
    <%= Html.Hidden("contactUsStatusUpdateOption")%>
    <%= Html.Hidden("SomeOTHERDATA")%>
    <%= Html.Hidden("Propertydetails")%>
    <% } %>

    <script type="text/javascript">
        var grid = $('#property-search-list');
        var previousRow = null;

        function refreshGrid() {
            grid.trigger('reloadGrid');
        }

        $().ready(function () {

            $('#dialog').dialog({
                modal: true,
                autoOpen: false
            });

            $('#notes-dialog').dialog({
                height: 200,
                modal: true,
                autoOpen: false
            });
            $('#bulk-dialog').dialog({
                height: 200,
                modal: true,
                autoOpen: false
            });

            $('#bulk-inspection-action-dialog').dialog({
                width: 400,
                height: 450,
                modal: true,
                autoOpen: false
            });

            $('#bulk-electrical-work-action-dialog').dialog({
                width: 400,
                height: 600,
                modal: true,
                autoOpen: false
            });

            $('#cancel-dialog').dialog({
                modal: true,
                autoOpen: false
            });

            grid.jqGrid({
                width: '1547',
                height: '1000',
                url: '<%= Url.Action("GetItems") %>',
                dataType: 'json',
                colNames: ['', 'PropertyInfoId', 'RowVersion', 'Id', 'Unit/Shop', 'House', 'Street', 'Suburb', 'State', 'PCode', 'Due', 'Booked', 'Agency', 'Property Manager', 'Tenant', 'Contact Number', 'Contact Notes', 'Key', 'Problem', 'Large Ladder', 'New', 'Overdue', 'IsElectricianRequired', 'IsCancelled', 'InspectionStatusEnum', 'Inspection', 'ElectricalWorkStatusEnum', 'Electrical Work', '', ''],
                colModel: [
                    { name: 'selectLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                    { name: 'id', index: 'Id', key: true, hidden: true, width: '30px', sortable: true, sorttype: 'int' },
                    { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                    { name: 'propertyNumber', index: 'PropertyNumber', hidden: false, width: '40px', align: 'right', sortable: true, sorttype: 'integer' },
                    { name: 'unitShopNumber', index: 'UnitShopNumber', hidden: false, width: '90px', align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'streetNumber', index: 'StreetNumber', hidden: false, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'streetName', index: 'StreetName', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'suburb', index: 'Suburb', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'state', index: 'State.Name', hidden: false, width: '50px', align: 'center', sortable: true, sorttype: 'text' },
                    { name: 'postCode', index: 'PostCode', hidden: false, width: '65px', align: 'center', sortable: true, sorttype: 'text' },
                    { name: 'nextServiceDate', index: 'NextServiceDate', hidden: false, width: '95px', align: 'center', sortable: true, sorttype: 'text ' },
                    { name: 'bookingDate', index: 'BookingDate', hidden: false, width: '95px', align: 'center', sortable: true, sorttype: 'text' },
                    { name: 'agencyName', index: 'Agency.Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'propertyManager', index: 'PropertyManager.Name', hidden: true, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'tenantName', index: 'TenantName', hidden: false, width: 200, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'tenantContactNumber', index: 'TenantContactNumber', hidden: false, width: 180, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'contactNotes', index: 'ContactNotes', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'keyNumber', index: 'KeyNumber', hidden: false, width: '60px', align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'hasProblem', index: 'HasProblem', hidden: true },
                    { name: 'hasLargeLadder', index: 'HasLargeLadder', hidden: true },
                    { name: 'isNew', index: 'IsNew', hidden: true },
                    { name: 'isOverDue', index: 'IsOverDue', hidden: true },
                    { name: 'isElectricianRequired', index: 'IsElectricianRequired', hidden: true },
                    { name: 'isCancelled', index: 'IsCancelled', hidden: true },
                    { name: 'inspectionStatusEnum', index: 'PropertyInfo.InspectionStatusId', hidden: true, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'inspectionStatus', index: 'InspectionStatus.Name', hidden: false, width: 220, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'electricalWorkStatusEnum', index: 'PropertyInfo.ElectricalWorkStatusId', hidden: true, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'electricalWorkStatus', index: 'ElectricalWorkStatus.Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                    { name: 'notesLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false }
                ],
                pager: '#pager',
                sortname: 'NextServiceDate',
                sortorder: 'asc',

                onRightClickRow: function (rowid, iRow, iCol, e) {
                    if (previousRow == null) {
                        previousRow = iRow;
                    } else {
                        if (iRow < previousRow) {
                            var swapRow = previousRow;
                            previousRow = iRow;
                            iRow = swapRow;
                        }

                        var dataIds = grid.getDataIDs();
                        for (var i = previousRow - 1; i < iRow; i++) {
                            grid.setRowData(dataIds[i], {
                                selectLink: '<input type="checkbox" checked="checked" name="selectedRow" value="' + dataIds[i] + '" onClick="var count = getPropertyCount();updatePropertyCounter(count);">'
                            });
                        }

                        previousRow = null;

                    }

                    updateCounter();

                },
                // Rjc added function to prevent initial loading of the grid
                loadComplete: function () {

                    var grid = $('#property-search-list');
                    var dataIds = grid.getDataIDs();

                    var rowCount = dataIds.length;

                    //                var height = (rowCount * 23) + 5;
                    //                grid.setGridHeight(height);
                    checkAll('Check_All', null, false);
                    var count = getPropertyCount();
                    updatePropertyCounter(count);



                },
                loadBeforeSend: function (xhr, settings) {
                    this.p.loadBeforeSend = null; //remove event handler
                    return false; // dont send load data request
                },

                ondblClickRow: function (id) {

                    var rowData = grid.getRowData(id);

                    openPropertyInfo(rowData.id);
                }



            });

            grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

            $('input[name=BulkElectricalWorkStatus]').click(updateApprovalCommunicationsBockVisibility);

            search(false);// rjc. false == don't refresh grid

        });

        function updateApprovalCommunicationsBockVisibility() {

            var bulkStatusRadioButtonsValue = $('input[name=BulkElectricalWorkStatus]:checked').val();

            if (bulkStatusRadioButtonsValue == 5 || bulkStatusRadioButtonsValue == 4) {
                $('#approvalCommunicationsBock').show();
            } else {
                $('#approvalCommunicationsBock').hide();
            }
        }

        function approvalCommunicationTypeChanged() {
            if ($('input[name=approvalCommunicationType]:checked').val() == "none") {
                $('#approvalComunicationDetailsBlock').hide();
            }
            else {
                if ($('input[name=approvalCommunicationType]:checked').val() == "email") {
                    $("#ElectricalWorkApprovalFaxSection").hide();
                    $("#ElectricalWorkApprovalEmailSection").show();
                }
                else {
                    // must be fax
                    $("#ElectricalWorkApprovalFaxSection").show();
                    $("#ElectricalWorkApprovalEmailSection").hide();
                }

                $('#approvalComunicationDetailsBlock').show();
            }
        }

        function updateCounter() {
            var count = getPropertyCount();
            updatePropertyCounter(count);
        }


        function updatePropertyCounter(count) {
            var counter = $('#property-count');
            counter.html(count);
        }

        function getPropertyCount(count) {
            var selectedRows = getCheckBoxListValues('selectedRow');
            updatePropertyCounter(selectedRows.length);
        }

        function confirmDelete(id, name, rowVersion) {
            $('#deleteTitle').text(unescape(name));

            var deleteDialog = $('#dialog');

            deleteDialog.dialog('option', 'buttons',
            {
                'No': function () {
                    $(this).dialog('close');
                },
                'Yes': function () {
                    $(this).dialog('close');


                    var form = $('#delete-form')[0];

                    form.action = '<%= Url.Action("Delete") %>/' + id;
                    form.submit();
                }
            });

            deleteDialog.dialog('open');
        }

        function showContactNotes(id, name, rowVersion) {

            var notesDialog = $('#notes-dialog');
            var updateContactNotes = $('#UpdateContactNotes');
            var rowData = grid.getRowData(id);
            updateContactNotes.val(rowData.contactNotes);
            notesDialog.dialog('option', 'buttons',
            {
                'No': function () {
                    $(this).dialog('close');
                },
                'Yes': function () {
                    var updateContactNotes = $('#UpdateContactNotes').val();
                    $.ajax({
                        url: '<%= Url.Action("ContactNotes", "Home") %>/' + id,
                        dataType: 'json',
                        data: { ContactNotes: updateContactNotes, RowVersion: rowVersion },
                        success: function (result) {
                            grid.setCell(id, 'contactNotes', updateContactNotes, null, '');
                            showInfoMessage('Success', 'Contact Notes saved.');
                        }
                    });
                    $(this).dialog('close');
                }
            });

            notesDialog.dialog('open');
        }

        function search(updateGrid) {
            var grid = $('#property-search-list');

            var isComingUpForService = $('#InspectionStatuses_IsComingUpForService').is(':checked');
            var dueForService = $('#Inspection_DueForService').is(':checked');
            var isNew = $('#InspectionStatuses_IsNew').is(':checked');
            var isOverDue = $('#InspectionStatuses_IsOverDue').is(':checked');
            var isElectricianRequired = $('#ElectricalWorkStatuses_IsOverDue').is(':checked');
            var keyword = $('#Keyword').val();
            var dateStart = $('#StartDate').val();
            var dateEnd = $('#EndDate').val();
            var agency = $('#AgencyId').val();
            var propertyManager = $('#PropertyManagerId').val();
            var hasProblem = $('#HasProblem').val();
            var cancelled = $('#Cancelled').val();
            var inspectionStatuses = getCheckBoxListValues('InspectionStatuses');
            var electricalWorkStatuses = getCheckBoxListValues('ElectricalWorkStatuses');

            if (updateGrid === undefined || updateGrid == true) {
                grid.jqGrid("setGridParam", { postData: null });
                grid.jqGrid("setGridParam", {
                    postData: {
                        IsComingUpForService: isComingUpForService,
                        DueForService: dueForService,
                        IsNew: isNew,
                        IsOverDue: isOverDue,
                        IsElectricianRequired: isElectricianRequired,
                        Keyword: keyword,
                        StartDate: dateStart,
                        EndDate: dateEnd,
                        AgencyId: agency,
                        PropertyManagerId: propertyManager,
                        HasProblem: hasProblem,
                        Cancelled: cancelled,
                        SelectedInspectionStatuses: inspectionStatuses,
                        SelectedElectricalWorkStatuses: electricalWorkStatuses
                    }
                });

                reloadGrid(grid);
            }


            //getStatusCounters();// Rjc stoped totals being automatically updated as this slows the page load quite a lot
            var count = getPropertyCount();
            updatePropertyCounter(count);

        }

        function clearSearch() {
            $('#StartDate').val('');
            $('#EndDate').val('');
            $('#AgencyId').val('');
            $('#PropertyManagerId').val('');
            $('#HasProblem').val('');
            $('#Cancelled').val('<%=Boolean.FalseString %>');
            $('#Keyword').val('');

            search();
        }

        function getStatusCounters() {
            var agency = $('#AgencyId').val();
            var propertyManager = $('#PropertyManagerId').val();
            var keyword = $('#Keyword').val();
            var dateStart = $('#StartDate').val();
            var dateEnd = $('#EndDate').val();
            var hasProblem = $('#HasProblem').val();

            var postData = '';
            if (agency != null) {
                postData = 'agencyId=' + agency;
            }

            if (propertyManager != null) {
                if (postData != '') {
                    postData = postData + '&';
                }
                postData = postData + 'propertyManagerId=' + propertyManager;
            }

            if (keyword) {
                postData += (postData != '' ? '&' : '') + 'keyword=' + keyword;
            }

            if (dateStart) {
                postData += (postData != '' ? '&' : '') + 'startDate=' + dateStart;
            }
            if (dateEnd) {
                postData += (postData != '' ? '&' : '') + 'endDate=' + dateEnd;
            }
            if (hasProblem) {
                postData += (postData != '' ? '&' : '') + 'hasProblem=' + hasProblem;
            }

            $.ajax({
                url: '<%= Url.Action("GetHasProblemCount", "Home") %>',
                data: postData,
                dataType: 'json',
                success: function (result) {
                    for (var i = 0; i < result.length; i++) {
                        var counter = $('#extra_hasProblem');
                        counter.html(' (' + result[i].Count + ')');

                    }
                },
                error: function (result) {
                    showInfoMessage('Failed', 'Could not load problems');
                }
            });

            $.ajax({
                url: '<%= Url.Action("GetInspectionStatusCount", "Home") %>',
                dataType: 'json',
                data: postData,
                success: function (result) {
                    var newCount = 0;
                    var overDueCount = 0;
                    var readyForServiceCount = 0;
                    for (var i = 0; i < result.length; i++) {
                        var counter = $('#extra_InspectionStatuses_' + result[i].Id);
                        counter.html(' (' + result[i].Count + ')');
                        newCount += parseInt(result[i].NewProperties);
                        overDueCount += parseInt(result[i].OverDue);
                        readyForServiceCount += parseInt(result[i].ComingUpForService);

                    }
                    var overDueCounter = $('#extra_InspectionStatuses_overdue');
                    overDueCounter.html(' (' + overDueCount + ')');

                    var newCounter = $('#extra_InspectionStatuses_new');
                    newCounter.html(' (' + newCount + ')');

                    var readyForServiceCounter = $('#extra_InspectionStatuses_ComingUpForService');
                    readyForServiceCounter.html(' (' + readyForServiceCount + ')');
                },
                error: function (result) {
                    showInfoMessage('Failed', 'Could not load statuses');
                }
            });


            $.ajax({
                url: '<%= Url.Action("GetElectricalWorkStatusCount", "Home") %>',
                dataType: 'json',
                data: postData,
                success: function (result) {
                    var overDueCount = 0;
                    for (var i = 0; i < result.length; i++) {
                        var counter = $('#extra_ElectricalWorkStatuses_' + result[i].Id);
                        counter.html(' (' + result[i].Count + ')');
                        overDueCount += parseInt(result[i].OverDue);

                    }
                    var overDueCounter = $('#extra_ElectricalWorkStatuses_overdue');
                    overDueCounter.html(' (' + overDueCount + ')');
                },
                error: function (result) {
                    showInfoMessage('Failed', 'Could not load statuses');
                }
            });

        }

        function showElectricalWorkBulkAction() {
            bulkElectricalWorkActionChanged();

            var selectedRows = $("#property-search-list").getGridParam('selarrrow');

            var bulkDialog = $('#bulk-electrical-work-action-dialog');

            bulkDialog.dialog('option', 'buttons',
                {
                    'No': function () {
                        $(this).dialog('close');
                    },
                    'Yes': function () {
                        $(this).dialog('close');

                        performElectricalWorkBulkAction();
                    }
                });


            approvalCommunicationTypeChanged();
            updateApprovalCommunicationsBockVisibility();
            bulkDialog.dialog('open');
        }

        function showInspectionBulkAction() {

            bulkInspectionActionChanged();

            var selectedRows = $("#property-search-list").getGridParam('selarrrow');

            var bulkDialog = $('#bulk-inspection-action-dialog');

            bulkDialog.dialog('option', 'buttons',
                {
                    'No': function () {
                        $(this).dialog('close');
                    },
                    'Yes': function () {
                        $(this).dialog('close');

                        performInspectionBulkAction();
                    }
                });

            bulkDialog.dialog('open');
        }


        function bulkInspectionActionChanged() {
            $('#actionTitle').text('Are you sure you want to perform the bulk action?');

            var bulkAction = $('input[name=BulkInspectionActionOption]:checked').val();

            $('#InspectionActionDateLabel').text('Date');
            var actionDate = $('#InspectionActionDate');
            var inspectionStatus = $('#BulkInspectionStatus');
            var cancellationNotes = $('#CancellationNotes');
            var discount = $('#BulkDiscount');


            var actionDateContainer = $('#InspectionActionDateContainer');
            var inspectionStatusContainer = $('#BulkInspectionStatusContainer');
            var cancellationNotesContainer = $('#CancellationNotesContainer');
            var discountContainer = $('#BulkDiscountContainer');
            var contactUsoptionsContainer = $('#ContactUsLetterOptionsContainer');

            inspectionStatusContainer.css('display', 'none');
            actionDateContainer.css('display', 'none');
            cancellationNotesContainer.css('display', 'none');
            discountContainer.css('display', 'none');
            contactUsoptionsContainer.css('display', 'none');

            switch (bulkAction) {
                case '<%=BulkAction.GenerateNotificationLetter.ToString("D") %>':
                    actionDate.val('');
                    actionDateContainer.css('display', 'block');
                    break;
                case '<%=BulkAction.ExportInspectionInvoice.ToString("D") %>':
                    actionDate.val('');
                    actionDateContainer.css('display', 'block');
                    actionDate.select();// rjc 20130314 

                    break;
                case '<%=BulkAction.GenerateEmailWithPropertyServiceHistory.ToString("D") %>':
                    break;
                case '<%=BulkAction.UpdateInspectionStatus.ToString("D") %>':
                    $('#actionTitle').text('Are you sure you want to update the inspection status of these properties?');
                    inspectionStatus.val('');
                    inspectionStatusContainer.css('display', 'block');
                    break;
                case '<%=BulkAction.HoldProperties.ToString("D") %>':
                    $('#actionTitle').text('Are you sure you want to hold these properties?');
                    actionDate.val('');
                    $('#InspectionActionDateLabel').text('Property held until');
                    actionDateContainer.css('display', 'block');
                    cancellationNotes.val('');
                    cancellationNotesContainer.css('display', 'block');
                    break;
                case '<%=BulkAction.CreateBulkList.ToString("D") %>':
                    break;
                case '<%=BulkAction.CancelProperties.ToString("D") %>':
                    $('#actionTitle').text('Are you sure you want to cancel these properties?');
                    cancellationNotes.val('');
                    cancellationNotesContainer.css('display', 'block');
                    break;
                case '<%=BulkAction.ApplyDiscount.ToString("D") %>':
                    $('#actionTitle').text('Are you sure you want to discount these properties?');
                    discount.val('');
                    discountContainer.css('display', 'block');
                    break;
                case '<%=BulkAction.GenerateContactUsLetter.ToString("D") %>':
                    contactUsoptionsContainer.css('display', 'block');
                    $('#BulkContactUsStatusDontUpate').prop('checked', true);
                    $('#BulkContactUsStatusUpate').prop('checked', false);

                    break;
                default:
                    break;
            }
        }


        function performInspectionBulkAction() {

            var selectedRows = getCheckBoxListValues('selectedRow');
            if (selectedRows.length < 1) {
                showErrorMessage('Bulk Action Failed', 'No properties were selected');
                return;
            }

            var bulkAction = $('input[name=BulkInspectionActionOption]:checked').val();
            var actionDate = $('#InspectionActionDate').val();
            var inspectionStatus = $('input[name=BulkInspectionStatus]:checked').val();
            var electricalWorkStatus = undefined;
            var cancellationNotes = $('#CancellationNotes').val();
            var discount = $('#BulkDiscount').val();


            var bulkDialog = $('#bulk-dialog');

            bulkDialog.dialog('option', 'buttons',
            {
                'No': function () {
                    $(this).dialog('close');
                },
                'Yes': function () {
                    $(this).dialog('close');

                    switch (bulkAction) {
                        case '<%=BulkAction.ExportProperties.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });

                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#bulkAction').val(bulkAction);
                            form.submit();
                            break;
                        case '<%=BulkAction.ExportInspectionInvoice.ToString("D") %>':


                            if (actionDate.length < 1) {
                                showErrorMessage('Bulk Action Failed', 'No date was supplied');
                                return;
                            }
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });

                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            });
                            $('#notificationDate').val(actionDate);
                            $('#inspectionStatus').val(<%=InspectionStatus.ReadyForService.ToString("D") %>);
                            $('#electricalWorkStatus').val('');
                            $('#bulkAction').val(bulkAction);
                            //   form.submit();
                            // Code Added By Arun for Message display after file download

                            $.ajax({
                                url: '<%= Url.Action("PerformBulkActionSecond", "Home") %>',
                                dataType: 'json',
                                data: form.serialize(),
                                success: function (result) {

                                    if (result.success != true) {
                                        showErrorMessage('Bulk Action Failed', result.message);
                                    }
                                    else {

                                        var additionalMessage = "";
                                        if (result.message) {
                                            additionalMessage = ": " + result.message;
                                        }
                                        //  var csvContent = "data:text/csv;charset=iso-8859-1,";
                                        //  var csvContent = "data:text/csv;charset=iso-8859-1,invoice.iif";

                                        var csvContent = result.file;
                                        //  csvContent += result.file;
                                        var mess = result.InvoiceMessage;
                                        if (mess != null) {
                                            showInfoMessage(mess);
                                        }

                                        // Response.AppendHeader("Content-Disposition", "attachment");
                                        //  var encodedUri = encodeURI(csvContent);
                                        // csvContent = csvContent.replace(/\/g,/);
                                        //alert(csvContent);
                                        // window.open(encodedUri, "_blank", "fullscreen=no, toolbar=yes,height=100;width:100;scrollbars =yes,resizable =yes");
                                        //   window.location.href = csvContent;
                                        // window.open("http://108.168.203.227/rdi/" + csvContent, "_blank", "bmarks", "chrome, 'toolbar=0,scrollbars=0,location=0,status=0,menubar=0,resizable=0,width=400,height=200");
                                        // window.open("108.168.203.227/rdi/"+csvContent, "_blank");
                                        //   window.open("http://localhost:61074/" + csvContent, "_blank", "bmarks", "attachment", "chrome, 'toolbar=0,scrollbars=0,location=0,status=0,menubar=0,resizable=0,width=400,height=200");
                                        //window.open("http://localhost:61074/" + csvContent, "_blank", "attachment","toolbar=0,scrollbars=0,location=0,status=0,menubar=0,resizable=0,width=400,height=200");
                                        window.open("http://localhost:61074/" + csvContent, "attachment");

                                      //  setTimeout(function () { window.close(); }, 5000);

                                    }
                                },
                                error:
                                    function (error) {
                                        //  alert("Error");
                                    }
                            });
                            break;
                        case '<%=BulkAction.GenerateNotificationLetter.ToString("D") %>':
                            if (actionDate.length < 1) {
                                showErrorMessage('Bulk Action Failed', 'No date was supplied');
                                return;
                            }
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });
                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#bulkAction').val(bulkAction);
                            $('#notificationDate').val(actionDate);
                            form.submit();
                            break;
                        case '<%=BulkAction.GenerateContactUsLetter.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });

                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#inspectionStatus').val(<%=InspectionStatus.ContactUsLetterSent.ToString("D") %>);
                            $('#electricalWorkStatus').val('');
                            $('#bulkAction').val(bulkAction);
                            var contactUsOptions = $('input[name=BulkContactUsUpdateStatusOption]:checked').val();

                            $('#contactUsStatusUpdateOption').val(contactUsOptions);
                            form.submit();
                            break;
                        case '<%=BulkAction.ExportForContactDetailsUpdate.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });
                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#electricalWorkStatus').val('');
                            $('#inspectionStatus').val(<%=InspectionStatus.AwaitingUpdatedDetails.ToString("D") %>);
                            $('#bulkAction').val(bulkAction);
                            form.submit();
                            break;
                        case '<%=BulkAction.RequestForContactDetailsUpdate.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });

                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#electricalWorkStatus').val('');
                            $('#inspectionStatus').val(<%=InspectionStatus.AwaitingUpdatedDetails.ToString("D") %>);
                            $('#bulkAction').val(bulkAction);
                            form.submit();
                            break;
                        case '<%=BulkAction.GenerateEmailWithPropertyServiceHistory.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });

                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#bulkAction').val(bulkAction);
                            form.submit();

                            break;
                        default:

                            if (bulkAction == '<%=BulkAction.HoldProperties.ToString("D") %>') {
                                inspectionStatus = '<%=InspectionStatus.PropertyOnHold.ToString("D") %>';
                            }
                            $.ajax({
                                url: '<%= Url.Action("PerformBulkAction", "Home") %>',
                                dataType: 'json',
                                data: { selectedRows: selectedRows, bulkAction: bulkAction, discount: discount, electricalWorkStatus: electricalWorkStatus, inspectionStatus: inspectionStatus, notes: cancellationNotes, notificationDate: actionDate },
                                success: function (result) {
                                    if (result.success != true) {
                                        showErrorMessage('Bulk Action Failed', result.message);
                                    }
                                    else {
                                        var additionalMessage = "";
                                        if (result.message) {
                                            additionalMessage = ": " + result.message;
                                        }
                                        showInfoMessage('Bulk Action Succeeded', 'Action successful' + additionalMessage);
                                    }
                                },
                                error:
                                    function (error) {

                                    }
                            });
                            $('#BulkInspectionStatus').val('');
                            $('#BulkElectricalWorkStatus').val('');
                            $('#BulkDiscount').val('');
                            $('#CancellationNotes').val('');
                            $('#InspectionActionDate').val('');
                            $('#ElectricalWorkActionDate').val('');
                            break;
                    }
                    search();
                }
            });
            bulkDialog.dialog('open');
        }

        function resetFormElement(e) {
            e.wrap('<form>').closest('form').get(0).reset();
            e.unwrap();
        }

        function bulkElectricalWorkActionChanged() {
            $('#actionTitle').text('Are you sure you want to perform the bulk action?');
            var cancellationNotes = $('#ElectricalWorkCancellationNotes');
            var cancellationNotesContainer = $('#ElectricalWorkCancellationNotesContainer');

            var bulkAction = $('input[name=BulkElectricalWorkActionOption]:checked').val();

            var actionDate = $('#ElectricalWorkActionDate');
            var electricalWorkStatus = $('input[name=BulkElectricalWorkStatus]:checked').val();
            var inspectionStatus = undefined;

            var actionDateContainer = $('#ElectricalWorkActionDateContainer');
            var electricalWorkStatusContainer = $('#BulkElectricalWorkStatusContainer');

            electricalWorkStatusContainer.css('display', 'none');
            actionDateContainer.css('display', 'none');
            cancellationNotesContainer.css('display', 'none');
            cancellationNotes.val('');

            resetFormElement($("#ElectricalWorkApprovalAttachment"));
            $('input[name=approvalCommunicationType][value=none]').attr('checked', true);
            $("input[name=ElectricalWorkApprovalEmailFrom]").val('');
            $("input[name=ElectricalWorkApprovalEmailTo]").val('');
            $("input[name=ElectricalWorkApprovalEmailDateTime]").val('');
            $("input[name=ElectricalWorkApprovalSubject]").val('');
            $("textarea[name=ElectricalWorkApprovalMessage]").val('');
            $("input[name=ElectricalWorkApprovalDateReceived]").val('');
            $("input[name=ElectricalWorkApprovalTimeReceived]").val('');


            switch (bulkAction) {
                case '<%=BulkAction.HoldProperties.ToString("D") %>':
                    $('#actionTitle').text('Are you sure you want to hold these properties?');
                    actionDate.val('');
                    actionDateContainer.css('display', 'block');
                    cancellationNotes.val('');
                    cancellationNotesContainer.css('display', 'block');
                    break;
                case '<%=BulkAction.UpdateElectricalWorkStatus.ToString("D") %>':
                    $('#actionTitle').text('Are you sure you want to update the electrical work status of these properties?');
                    electricalWorkStatusContainer.css('display', 'block');
                    break;
                default:
                    $('#BulkDiscount').val('');
                    $('#CancellationNotes').val('');
                    $('#InspectionActionDate').val('');
                    $('#ElectricalWorkActionDate').val('');
                    break;
            }
        }

        function performElectricalWorkBulkAction() {
            var selectedRows = getCheckBoxListValues('selectedRow');
            if (selectedRows.length < 1) {
                showErrorMessage('Bulk Action Failed', 'No properties were selected');
                return;
            }

            var bulkAction = $('input[name=BulkElectricalWorkActionOption]:checked').val();
            var actionDate = $('#ElectricalWorkActionDate').val();
            var electricalWorkStatus = $('input[name=BulkElectricalWorkStatus]:checked').val();
            var inspectionStatus = undefined;
            var cancellationNotes = $('#ElectricalWorkCancellationNotes').val();
            var discount = $('#BulkDiscount').val();
            var contactUsOptions = $('#BulkContactUsStatus').val();


            var bulkDialog = $('#bulk-dialog');

            bulkDialog.dialog('option', 'buttons',
            {
                'No': function () {
                    $(this).dialog('close');
                },
                'Yes': function () {
                    $(this).dialog('close');

                    switch (bulkAction) {
                        case '<%=BulkAction.GenerateElectricalApprovalQuotation.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });
                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#electricalWorkStatus').val(<%=ElectricalWorkStatus.AwaitingElectricalApproval.ToString("D") %>);
                            $('#inspectionStatus').val('');
                            $('#bulkAction').val(bulkAction);

                            var option1 = '<input type="text" name="SOMETEXT" value="TEXTVALUE"/>';
                            form.append(option1);

                            form.submit();
                            break;
                        case '<%=BulkAction.GenerateElectricanJobReport.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });
                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#electricalWorkStatus').val(<%=ElectricalWorkStatus.ContactDetailsSentToElectrician.ToString("D") %>);
                            $('#inspectionStatus').val('');
                            $('#bulkAction').val(bulkAction);
                            form.submit();
                            break;
                        case '<%=BulkAction.GenerateContactUsLetter.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });
                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#electricalWorkStatus').val(<%=ElectricalWorkStatus.ContactUsLetterSent.ToString("D") %>);
                            $('#inspectionStatus').val('');
                            $('#bulkAction').val(bulkAction);
                            form.submit();
                            break;
                        case '<%=BulkAction.RequestForContactDetailsUpdate.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });
                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#electricalWorkStatus').val(<%=ElectricalWorkStatus.AwaitingUpdatedDetails.ToString("D") %>);
                            $('#inspectionStatus').val('');
                            $('#bulkAction').val(bulkAction);
                            form.submit();
                            break;
                        case '<%=BulkAction.ExportForContactDetailsUpdate.ToString("D") %>':
                            var form = $('#bulk-form');
                            var items = $('#bulk-form input[name=selectedRows]');
                            items.each(function () {
                                $(this).remove();
                            });
                            $.each(selectedRows, function (i, item) {
                                var option = '<input type="hidden" name="selectedRows" value="' + item + '"';
                                option += '>';
                                form.append(option);
                            })
                            $('#electricalWorkStatus').val(<%=ElectricalWorkStatus.AwaitingUpdatedDetails.ToString("D") %>);
                            $('#inspectionStatus').val('');
                            $('#bulkAction').val(bulkAction);
                            form.submit();
                            break;
                        case '<%=BulkAction.GenerateEmailWithPropertyServiceHistory.ToString("D") %>':
                            var form = $('#bulk-form');
                            $('#bulkAction').val(bulkAction);
                            form.submit();
                            break;
                        default:
                            if (bulkAction == '<%=BulkAction.HoldProperties.ToString("D") %>') {
                                electricalWorkStatus = '<%=ElectricalWorkStatus.PropertyOnHold.ToString("D") %>';
                            }
                            var approvalDoc = $("#ElectricalWorkApprovalAttachment");
                            var approvalCommunicationType = $("input[name=approvalCommunicationType]:checked").val();
                            var electricalWorkApprovalEmailFrom = escape($("input[name=ElectricalWorkApprovalEmailFrom]").val());
                            var electricalWorkApprovalEmailTo = escape($("input[name=ElectricalWorkApprovalEmailTo]").val());
                            var electricalWorkApprovalEmailDateTime = escape($("input[name=ElectricalWorkApprovalEmailDateTime]").val());
                            var electricalWorkApprovalSubject = escape($("input[name=ElectricalWorkApprovalSubject]").val());
                            var electricalWorkApprovalMessage = escape($("textarea[name=ElectricalWorkApprovalMessage]").val());
                            var electricalWorkApprovalDateReceived = escape($("input[name=ElectricalWorkApprovalDateReceived]").val());
                            var electricalWorkApprovalTimeReceived = escape($("input[name=ElectricalWorkApprovalTimeReceived]").val());

                            var theData = {
                                selectedRows: selectedRows, bulkAction: bulkAction,
                                discount: discount, electricalWorkStatus: electricalWorkStatus,
                                inspectionStatus: inspectionStatus, notes: cancellationNotes,
                                notificationDate: actionDate,
                                approvalCommunicationType: approvalCommunicationType,
                                electricalWorkApprovalEmailFrom: electricalWorkApprovalEmailFrom,
                                electricalWorkApprovalEmailTo: electricalWorkApprovalEmailTo,
                                electricalWorkApprovalEmailDateTime: electricalWorkApprovalEmailDateTime,
                                electricalWorkApprovalDateReceived: electricalWorkApprovalDateReceived,
                                electricalWorkApprovalTimeReceived: electricalWorkApprovalTimeReceived,
                                electricalWorkApprovalSubject: electricalWorkApprovalSubject,
                                electricalWorkApprovalMessage: electricalWorkApprovalMessage,
                                attachmentData: "",
                                attachmentFileName: ""
                            };

                            if (approvalDoc[0].files.length > 0) {

                                approvalDoc = approvalDoc[0].files[0];
                                var reader = new FileReader();

                                reader.onload = function (event) {
                                    theData.attachmentFileName = approvalDoc.name;
                                    theData.attachmentData = event.target.result;
                                    //alert("Call processAppovalAjax With Data");
                                    processApprovalAjax(theData);

                                };
                                reader.readAsDataURL(approvalDoc);
                            }
                            else {
                                //alert("Call processAppovalAjax NO Data");
                                processApprovalAjax(theData);
                            }
                            break;
                    }
                    search();
                }
            });
            bulkDialog.dialog('open');
        }
        function processApprovalAjax(theData) {
            //alert("processAppovalAjax"); 
            $.ajax({
                url: '<%= Url.Action("PerformBulkAction", "Home") %>',
                dataType: 'json',
                data: theData,
                success: function (result) {
                    if (result.success != true) {
                        showErrorMessage('Bulk Action Failed', result.message);
                    }
                    else {
                        showInfoMessage('Bulk Action Succeeded', 'Action successful');
                    }
                }
            });
            $('#BulkDiscount').val('');
            $('#CancellationNotes').val('');
            $('#InspectionActionDate').val('');
            $('#ElectricalWorkActionDate').val('');
        }

        function agencyChanged() {
            var agencyId = $('#AgencyId').val();
            $.ajax({
                url: '<%= Url.Action("GetPropertyManagersForAgency", "Home", new { area="Agency", agencyId="_ID_", propertyInfoId = 0 }) %>'.replace(/_ID_/g, agencyId),
                dataType: 'json',
                success: function (result) {
                    $('#PropertyManagerId option').remove();
                    $.each(result, function (i, item) {
                        var option = '<option value="' + item.Value + '"';
                        if (item.Selected == true) {
                            option += ' selected="selected"';
                        }
                        option += '>' + item.Text + '</option>';
                        $('#PropertyManagerId').append(option);
                    })
                }
            });
        }
    </script>
    <div id="bulk-inspection-action-dialog" style="display: none;" title="Perform Inspection Status Bulk Action">
        <div class="row">
            <%= Html.RadioButtonList("BulkInspectionActionOption", Model.BulkInspectionActionOptions, string.Empty, new { onClick="javascript:bulkInspectionActionChanged();", @class="radiobutton-list bulk-action", style="width: 280px; display: block;"})%>
        </div>
        <div class="clear divider"></div>
        <div id="BulkInspectionStatusContainer" class="row">
            <label for="InspectionStatus">Inspection Status</label>
            <div class="clear"></div>
            <%= Html.RadioButtonList("BulkInspectionStatus", Model.UpdateInspectionStatuses, string.Empty, new { @class="radiobutton-list bulk-action", style="width: 280px; display: block;"})%>
        </div>
        <div id="BulkDiscountContainer" class="row">
            <label for="BulkDiscount">Discount %</label>
            <div class="clear"></div>
            <%= Html.TextBox("BulkDiscount", string.Empty, new { @class = "money" })%>
        </div>
        <div id="CancellationNotesContainer" class="row">
            <label for="CancellationNotes">Notes</label>
            <div class="clear"></div>
            <%= Html.TextArea("CancellationNotes",string.Empty) %>
        </div>
        <div id="InspectionActionDateContainer" class="row">
            <label id="InspectionActionDateLabel" for="InspectionActionDate">Date</label>
            <div class="clear"></div>
            <%= Html.TextBox("InspectionActionDate", string.Empty, new { @class = "datepicker", style = "width: 124px; " })%>
        </div>

        <div id="ContactUsLetterOptionsContainer" class="row">
            <label for="InspectionStatusChange">Status update options</label>
            <div class="clear"></div>
            <input id="BulkContactUsStatusDontUpate" type="radio" value="DontUpdateStatus" name="BulkContactUsUpdateStatusOption" checked="checked" />
            Don't update Inspection status<br />
            <input id="BulkContactUsStatusUpdate" type="radio" value="UpdateStatus" name="BulkContactUsUpdateStatusOption" />
            Update Inspection status
        </div>

    </div>

    <div id="bulk-electrical-work-action-dialog" style="display: none;" title="Perform Electrical Work Status Bulk Action">
        <div class="row">
            <%= Html.RadioButtonList("BulkElectricalWorkActionOption", Model.BulkElectricalWorkActionOptions, string.Empty, new { onClick="javascript:bulkElectricalWorkActionChanged();", @class="radiobutton-list bulk-action", style="width: 280px; display: block;"})%>
        </div>
        <div class="clear divider"></div>
        <div id="BulkElectricalWorkStatusContainer" class="row">
            <div>
                <label for="ElectricalWorkStatus">Electrical Work Status</label>
                <div class="clear"></div>
                <%= Html.RadioButtonList("BulkElectricalWorkStatus", Model.UpdateElectricalWorkStatuses, string.Empty, new { @class="radiobutton-list bulk-action", style="width: 280px; display: block;"})%>
            </div>
            <div id="approvalCommunicationsBock" style="display: none; margin-top: 20px;">
                <div>
                    <b>Communication type:<br />
                        <br />
                    </b>
                    <input type="radio" name="approvalCommunicationType" value="none" checked="checked" onclick="approvalCommunicationTypeChanged();" />None 
				<input type="radio" name="approvalCommunicationType" value="email" onclick="approvalCommunicationTypeChanged();" />Email 
				<input type="radio" name="approvalCommunicationType" value="fax" onclick="approvalCommunicationTypeChanged();" />Fax<br />
                    <br />
                </div>
                <div id="approvalComunicationDetailsBlock">
                    <div id="ElectricalWorkApprovalEmailSection" style="display: none;">
                        <label for="ElectricalWorkApprovalEmailFrom" id="ElectricalWorkApprovalEmailFromLabel">Email From:</label>
                        <div class="clear"></div>
                        <%= Html.TextBox("ElectricalWorkApprovalEmailFrom", string.Empty,new { style = "width: 250px; " })%><br />
                        <label for="ElectricalWorkApprovalEmailDateTime" id="Label3">Email Sent Date/Time:</label>
                        <div class="clear"></div>
                        <%= Html.TextBox("ElectricalWorkApprovalEmailDateTime", string.Empty,new { style = "width: 250px; " })%><br />
                        <label for="ElectricalWorkApprovalEmailTo" id="ElectricalWorkApprovalEmailToLabel">Email To:</label>
                        <div class="clear"></div>
                        <%= Html.TextBox("ElectricalWorkApprovalEmailTo", string.Empty,new { style = "width: 250px; " })%><br />

                    </div>
                    <div id="ElectricalWorkApprovalFaxSection" style="display: none;">
                        <label for="ElectricalWorkApprovalFaxDateReceived" id="Label1">Date Received:</label>
                        <div class="clear"></div>
                        <%= Html.TextBox("ElectricalWorkApprovalDateReceived", string.Empty,new { @class = "datepicker", style = "width: 124px; " })%><br />
                        <label for="ElectricalWorkApprovalFaxTimeReceived" id="Label2">Time Received:</label>
                        <div class="clear"></div>
                        <%= Html.TextBox("ElectricalWorkApprovalTimeReceived", string.Empty,new { style = "width: 250px; " })%><br />
                    </div>
                    <label for="ElectricalWorkApprovalSubject">Subject:</label>
                    <div class="clear"></div>
                    <%= Html.TextBox("ElectricalWorkApprovalSubject", string.Empty,new { style = "width: 250px; " })%><br />
                    <label for="ElectricalWorkApprovalMessage">Message:</label>
                    <div class="clear"></div>
                    <%= Html.TextArea("ElectricalWorkApprovalMessage", string.Empty, new { style = "width: 250px; " })%><br />

                </div>
                <div>
                    <input type="file" name="ElectricalWorkApprovalAttachment" id="ElectricalWorkApprovalAttachment" />
                </div>
            </div>
        </div>
        <div id="ElectricalWorkCancellationNotesContainer" class="row">
            <label for="ElectricalWorkCancellationNotes">Notes</label>
            <div class="clear"></div>
            <%= Html.TextArea("ElectricalWorkCancellationNotes", string.Empty)%>
        </div>
        <div id="ElectricalWorkActionDateContainer" class="row">
            <label for="ElectricalWorkActionDate">Date</label>
            <div class="clear"></div>
            <%= Html.TextBox("ElectricalWorkActionDate", string.Empty, new { @class = "datepicker", style = "width: 124px; " })%>
        </div>
    </div>
    <div id="notes-dialog" style="display: none;" title="Contact Notes">
        <div id="contact-notes" class="row">
            <%= Html.TextArea("UpdateContactNotes", new { style = "width: 100%;height: 100px;" })%>
        </div>
    </div>
    <div id="dialog" style="display: none;" title="Delete Item">
        <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>Are you sure you want to delete the item &quot;<span id="deleteTitle"></span>&quot;?</p>
    </div>
    <div id="bulk-dialog" style="display: none;" title="Bulk Action">
        <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span><span id="actionTitle">Are you sure you want to perform the bulk action?</span></p>
    </div>
    <%} %>
</asp:Content>


