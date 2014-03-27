<%@ Page Title="Booking Management" Language="C#" MasterPageFile="~/Views/Shared/WideScreen.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Booking.ViewModels.BookingSearchViewModel>" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

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
                      window.opener.refreshGrid();
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


<fieldset style="width: 1570px;">    
    <h2>Booking Management</h2>

    <div class="row">
        <label for="BookingDate" style="width: 95px;">Booking Date</label>
	    <%= Html.TextBox("BookingDate", StringFormatter.LocalDate(Model.BookingDate), new { @class = "datepicker textbox", style = "width: 125px;margin-right: 10px; " })%>
        <input type="button" onclick="refreshBookings(false);" value="Refresh"  class="button ui-corner-all ui-state-default" />
        <input type="button" onclick="showAllocation();" value="Allocate"  class="button ui-corner-all ui-state-default" />
        <input type="button" onclick="performBulkAction();" value="Export All Mobile Numbers"  class="button ui-corner-all ui-state-default" />
    </div>
</fieldset>
<input type="hidden" id="technicianIds" name="technicianIds" value="" />

<% using (Html.BeginForm("PerformBulkAction", "Home", new { area = "PropertyInfo" }, FormMethod.Post, new { id = "bulk-form" }))
   {%>
    <%= Html.Hidden("bulkAction")%>
    <%= Html.Hidden("notificationDate")%>
<% } %>
<div class="clear"></div>
<div id="placeholder"></div>

<% using (Html.BeginForm("Delete", "Home", FormMethod.Post, new { id = "delete-form" }))
   {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("RowVersion")%>
<% } %>

<script type="text/javascript">
    var technicianIds = new Array();

    $().ready(function () {
       
        refreshBookings(true);

        $('#bulk-action-dialog').dialog({
            height: 200,
            modal: true,
            autoOpen: false
        });
        $('#bulk-dialog').dialog({
            height: 200,
            modal: true,
            autoOpen: false
        });
        
        $('#dialog').dialog({
            modal: true,
            autoOpen: false
        });
        

    });

    
    function performBulkAction() {
        var notificationDate = $('#BookingDate').val();
        var bulkAction = '<%=BulkAction.ExportMobileNumberForSMS.ToString("D") %>';

        var form = $('#bulk-form');
        $('#bulkAction').val(bulkAction);
        $('#notificationDate').val(notificationDate);
        form.submit();

    }


    function initSetup(startup) {
        var bookingDate = $('#BookingDate').val();
        if(startup)
        {
            setTechnician('Unallocated',0);
            setSlot(bookingDate, 'Key Entry',0, 0, false);
            setSlot(bookingDate, 'Appointments',0, 1, false);
        }
        else
        {
            refreshSlot(bookingDate, 'Key Entry',0, 0);
            refreshSlot(bookingDate, 'Appointments',0, 1);
        }

    <%
        foreach(var technician in Model.Technicians)
        {
    %>
            if(startup)
            {
                technicianIds.push(<%=technician.Id %>);
                setTechnician('<%=technician.Name %>',<%=technician.Id %>);
            }
    <%
            var techDate = DateTime.Today.AddHours(9);
    %>
            if(startup)
            {
                setSlot(bookingDate, 'Key Entry',<%=technician.Id %>, 0, true);
                setSlot(bookingDate, 'Appointments',<%=technician.Id %>, 1, true);
            }
            else
            {
                refreshSlot(bookingDate, 'Key Entry',<%=technician.Id %>, 0);
                refreshSlot(bookingDate, 'Appointments',<%=technician.Id %>, 1);
            }
    <%
        }
    %>
        $('#technicianIds').val(technicianIds.join(','));
        
    }

    function refreshSlot(bookingDate, caption, technician_id, row_id)
    {
         var row_name = findRowName(caption);
         var time = caption;
         var technicianId = technician_id;
         if(row_id < 1)
         {
            time = null;
         }
         if(technicianId < 1)
         {
            technicianId = null;
         }
         
         var slotGrid = $('#slot' + technician_id + '_' + row_name);
         var dataIds = slotGrid.getDataIDs();

         slotGrid.setGridHeight(0);

        for (var i = 0; i < dataIds.length; i++) {

            slotGrid.delRowData(dataIds[i]);

        }

        refreshCounter(technician_id, row_name);
    }

    var updateGridHeight = function($gridElement) {
        var $grid = $gridElement.jqGrid();
        var rowCount = $grid.getDataIDs().length;
        var height = ((rowCount * 22) + 5);
                    
        var accordian = $grid.parents('.ui-jqgrid').parent();
        if (accordian.is(':visible')) {
            $grid.setGridHeight(height);    
        }
    };
    
    function loadBookings() {
         var bookingDate = $('#BookingDate').val();

         $.ajax({
             url: '<%= Url.Action("GetBookingsForDate", "Home", new { area = "Booking", BookingDate="_BOOKINGDATE_" }) %>'.replace(/_BOOKINGDATE_/g, escape(bookingDate)),
             dataType: 'json',
             success: function (result) {
                 $.each(result.items, function (i, item) {
                    var slotGrid = findGrid(item);
                    addGridRow(slotGrid, item);
                });


                 
                refreshTechnicians(bookingDate, technicianIds);
                 
               $('#placeholder .ui-jqgrid-btable').each(function() {
                   updateGridHeight($(this));
               });
             },
             error: function (result) {
                 showInfoMessage('Failed', 'Could not load bookings');
             }
         });

         showTechnicians();

     }    

     function refreshBookings(startup)
     {
        initSetup(startup);
        loadBookings();
     }
    
    function setTechnician(name, technician_id)
    {
        var placeHolder = $('#placeholder');
        placeHolder.append('<fieldset id="frameset' + technician_id + '" style="width: 1570px; float:left; margin: 0px 5px 0px 0px; display:block;"><legend>' + name + '</legend><div id="conditions' + technician_id + '"></div><div id="source' + technician_id + '"></div></fieldset><div class="clear"></div>');
    }


    function setSlot(bookingDate, caption, technician_id, row_id, isHidden)
    {
         var row_name = findRowName(caption);
         var time = caption;
         var technicianId = technician_id;
         if(row_id < 1)
         {
            time = null;
         }
         if(technicianId < 1)
         {
            technicianId = null;
         }
         

                            
        var slotPreviousRow = null;
         $("#source" + technician_id).append("<div style='padding: 4px; border: 1px #CCCCCC solid;margin: 0px 0px 1px 0px; background-color: #EEEEEE;'><div id='toggle" + technician_id + "_" + row_name + "' style='margin: 0px 5px 0px 0px; width: 90px;'>" + caption + "&nbsp;(<span id='count" + technician_id + "_" + row_name + "'>0</span>)</div><div id='area" + technician_id + "_" + row_name + "' style='margin: 5px 0px 0px 0px;'><table id='slot" + technician_id + "_" + row_name + "'></table></div><div class='clear'></div></div>");
         var slotGrid = $('#slot' + technician_id + '_' + row_name);
         slotGrid.jqGrid({
            width: '1547',
            height: '0',
            datatype: 'local',
            colNames: ['', '', '', 'Id', 'RowVersion', 'Unit', 'House', 'Street', 'Suburb', 'State', 'PCode', 'Agency', 'Key Number',  'Key/Time', 'Notes', 'Tenant', 'Contact Number', 'Large Ladder', '',''],
            colModel: [
                { name: 'selectLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'id', index: 'Id', key: true, hidden: true, width: 100 },
                { name: 'propertyInfoId', index: 'propertyInfoId', hidden: true, width: '60px', align: 'left', sortable: true, sorttype: 'int' },
                { name: 'propertyNumber', index: 'propertyNumber', hidden: false, width: '50px', align: 'right', sortable: true, sorttype: 'integer' },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                { name: 'unitShopNumber', index: 'unitShopNumber', hidden: false, width: '60px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'streetNumber', index: 'streetNumber', hidden: false, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'streetName', index: 'streetName', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'suburb', index: 'suburb', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'state', index: 'state', hidden: false, width: '70px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'postCode', index: 'postCode', hidden: false, width: '75px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'agencyName', index: 'agencyName', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'keyNumber', index: 'keyNumber', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'keyTime', index: 'keyTime', hidden: false, width: '160px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'notes', index: 'notes', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'tenantName', index: 'tenantName', hidden: false, width: 200, align: 'left', sortable: false, sorttype: 'text' },
                { name: 'tenantContactNumber', index: 'tenantContactNumber', hidden: false, width: 200, align: 'left', sortable: false, sorttype: 'text' },
                { name: 'hasLargeLadder', index: 'hasLargeLadder', hidden: false, width: '110px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            sortname: 'Id',
            sortorder: 'asc',
            ondblClickRow: function (id) {
                openBooking(id, undefined, false);
            },
            onRightClickRow: function (rowid, iRow, iCol, e) 
            {
                iRow--;
                if (slotPreviousRow == null) {
                    slotPreviousRow = iRow;
                } else {
                    if (iRow < slotPreviousRow) {
                        var swapRow = slotPreviousRow;
                        slotPreviousRow = iRow;
                        iRow = swapRow;
                    }

                    var dataIds = slotGrid.getDataIDs();
                    for (var i = slotPreviousRow; i <= iRow; i++) {
                        slotGrid.setRowData(dataIds[i], {
                            selectLink: '<input type="checkbox" checked="checked" name="selectedRow" value="' + dataIds[i] + '" >'
                        });
                    }
                    slotPreviousRow = null;
                }
            }
        });

        if(isHidden)
        {
            $("#area"+ technician_id + "_" + row_name).hide();
        }

        $("#toggle"+ technician_id + "_" + row_name).click(function()
        {
            $("#area"+ technician_id + "_" + row_name).slideToggle(0, function () {
                var $this = $(this);
                if ($this.is(':visible')) {
                    updateGridHeight($('.ui-jqgrid-btable', $this));
                }
            });
        });        

        
    }

    function findRowName(caption)
    {
        return caption.replace(/:/g, '').replace(/ /g, '');
    }

    function findGrid(item)
    {
        var technician_id = 0;
        var row_name = 'KeyEntry';
        if(item.technicianId != '')
        {
            technician_id = item.technicianId;
        }

        if(item.bookingTime != '')
        {
            //row_name = findRowName(item.bookingTime);
            row_name = findRowName('Appointments');
        }

        return $('#slot' + technician_id + '_' + row_name);
    }

    function refreshCounter(technician_id, row_name)
    {
        $('#count' + technician_id + '_' + row_name).html('0');
    }

    function showTechnicians()
    {
        var technicianIds = $('#technicianIds').val().split(',');
        
        for(var i = 0;i<technicianIds.length;i++)
        {
            var keyGrid = $('#slot' + technicianIds[i] + '_KeyEntry');
            var keyCounter = 0;
            if(keyGrid.length > 0)
            {
                var dataIds = keyGrid.getDataIDs(); 
                keyCounter = dataIds ? dataIds.length : 0;
            }
            var appGrid = $('#slot' + technicianIds[i] + '_Appointments');
            var appCounter = 0;
            if(appGrid.length > 0)
            {
                var dataIds = appGrid.getDataIDs();
                appCounter = dataIds ? dataIds.length : 0;
            }
            if(appCounter > 0 || keyCounter > 0)
            {
                $('#frameset' + technicianIds[i]).css('display', 'block');
            }
        }
    }

    function setCounter(item)
    {
        var technician_id = 0;
        var row_name = 'KeyEntry';
        if(item.technicianId != '')
        {
            technician_id = item.technicianId;
        }

        if(item.bookingTime != '')
        {
            row_name = findRowName('Appointments');
        }

        var counter = $('#count' + technician_id + '_' + row_name);
        var count = parseInt(counter.html());
        count++;
        counter.html(count.toString());
    }

    function addGridRow(grid, item)
    {

        var theRow = grid.addRowData(item.id, { id: item.id,
                            propertyInfoId: item.propertyInfoId,
                            propertyNumber: item.propertyNumber,
                            unitShopNumber: item.unitShopNumber,
                            streetNumber: item.streetNumber,
                            streetName: item.streetName,
                            suburb: item.suburb,
                            state: item.state,
                            lastServicedDate: item.lastServicedDate,
                            nextServiceDate: item.nextServiceDate,
                            keyNumber: item.keyNumber,
                            tenantName: item.tenantName,
                            tenantContactNumber: item.tenantContactNumber,
                            hasProblem: item.hasProblem,
                            hasLargeLadder: item.hasLargeLadder,
                            bookingDate: item.bookingDate,
                            bookingTime: item.bookingTime,
                            technicianId: item.technicianId,
                            technicianName: item.techicianName,
                            duration: item.duration,
                            agencyName: item.agencyName,
                            propertyManager: item.propertyManager,
                            postCode: item.postCode,
                            notes: item.notes,
                            keyTime: item.keyTime  });


        grid.setRowData(item.id, {
            selectLink: '<input type="checkbox" name="selectedRow" value="' + item.id + '">',
            editLink: '<a href="#" onclick="openBooking(' + item.id + ', ' + item.propertyInfoId +', false);return false;" class="button-edit">Edit</a>',
            deleteLink: '<a href="#" onclick="confirmDelete(\'' + item.id + '\', \'' + escape(item.name) + '\', \'' + item.rowVersion + '\',this,'+grid.getGridParam('reccount')+'); return false;" class="button-delete">Cancel</a>'

        });

        setCounter(item);
        /*var rowCount = grid.getDataIDs().length;
    
        var height = (rowCount * 22) + 5;          
        grid.setGridHeight(height + 50);*/

    }
     
    function confirmDelete(id, name, rowVersion,thisbutton,rowNum) 
    {
        $('#deleteTitle').text(unescape(name));
        var deleteDialog = $('#dialog');
    
        var r = $(thisbutton).closest("tr");


        theGrid = $( "#"+ r.closest("table").attr("id")  );



       // alert(theGrid.jqGrid.getGridParam('reccount'));

        //.jqGrid('delRowData',)
        
/*

var s="";
$.each(thisGrid, function(key, element) {
    s+='key: ' + key + '\n' + 'value: ' + element+'\n';
});

alert(s);
return;
*/


        var updateContactNotes = $('#UpdateContactNotes');

        updateContactNotes.val(r.children().eq(14).text());
 


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
                        success: function (result)
                        {
                            if (result.success != true) {
                                showErrorMessage('Booking not cancelled', result.message);
                            }
                            else {
                                //grid.setCell(id, 'contactNotes', updateContactNotes, null, '');
                                //loadBookings();

                               // alert($(gridID).jqGrid('getGridParam', 'selrow'));
                                //                                $(gridID).jqGrid('delRowData',);
                                r.hide();// Just hide the row as its already deleted and it takes ages to reload.

                                showInfoMessage('Booking cancelled', result.message);
                            }
                        }
                    });
                    $(this).dialog('close');
                }
            });
            deleteDialog.dialog('open');
        }

    function showAllocation() {

        var bulkDialog = $('#bulk-action-dialog');

        bulkDialog.dialog('option', 'buttons',
            {
                'No': function () {
                    $(this).dialog('close');
                },
                'Yes': function () {
                    $(this).dialog('close');

                    performAllocation();
                }
            });

        bulkDialog.dialog('open');
    }

    function performAllocation() {
        var selectedRows = getCheckBoxListValues('selectedRow');
        var technicianId = $('#AllocateTechnicianId').val();
        var time = $('#AllocateTime').val();
        var duration = $('#AllocateDuration').val();
        var bulkDialog = $('#bulk-dialog');

        bulkDialog.dialog('option', 'buttons',
        {
            'No': function () {
                $(this).dialog('close');
            },
            'Yes': function () {
                $(this).dialog('close');
                $.ajax({
                    url: '<%= Url.Action("AllocateTechnician", "Home") %>',
                    dataType: 'json',
                    data: { selectedRows: selectedRows, technicianId: technicianId, time: time, duration: duration },
                    success: function (result) {
                        if(result.success != true)
                        {
                            showErrorMessage('Allocate Failed', result.message);
                        }
                        else{
                            showInfoMessage('Allocate Succeeded', result.message);
                        }
                        refreshBookings(false);
                    }
                });
                $('#AllocateTechnicianId').val('');
                $('#AllocateTime').val('');
                $('#AllocateDuration').val('');

            }
        });

        bulkDialog.dialog('open');

    }

     function refreshTechnicians(bookingDate, technicianIds) {
        
        $.ajax({
            dataType: 'json',
            url: '<%= Url.Action("AvailableTechnicianList", "TechnicianAvailability", new { area = "Technician", date="_BOOKINGDATE_" }) %>'.replace(/_BOOKINGDATE_/g, escape(bookingDate)),
            success: function (result) {
                for(var i = 0;i<technicianIds.length;i++)
                {
                    $('#frameset' + technicianIds[i]).css('display', 'none');
                    $('#conditions' + technicianIds[i]).html('<div style="color: red; margin: 0px 0px 10px 5px;">Unavailable</div>');
                }

                $('#AllocateTechnicianId option').remove();
                var option = '<option value="">-- Unallocated --</option>';
     			$('#AllocateTechnicianId').append(option);

                $.each(result, function (i, item) {
                    $('#frameset' + item.id).css('display', 'block');
                    $('#conditions' + item.id).html(item.conditions);
                    var option = '<option value="' + item.id + '"';
     				if(item.Selected == true) {
     					option += ' selected="selected"';
     				}
     				option += '>' + item.name + '</option>';
     				$('#AllocateTechnicianId').append(option);
                });
            },
            error: function (result) {
                showInfoMessage('Failed', 'Could not load technicians');
            }
        });

    }

    function refreshGrid()
    {
        refreshBookings(false);
    }



</script>


<div id="bulk-action-dialog" style="display:none;" title="Allocate">
    <div class="row">
        <label for="AllocateTechnicianId" style="width: 95px;">Technician</label>
	    <%= Html.DropDownList("AllocateTechnicianId", Model.TechnicianSelectList, "-- Unallocated --", new { style = "width: 130px; margin-right: 10px;" })%>       
    </div>   
    <div class="row">
        <label for="AllocateTime" style="width: 95px;">Time</label>
        <%= Html.TextBox("AllocateTime", string.Empty, new { style = "width: 125px;" })%>
    </div>
    <div class="row">
        <label for="AllocateDuration" style="width: 95px;">Duration</label>
        <%= Html.DropDownList("AllocateDuration", Model.Durations, "-- Unchanged --", new { style = "width: 130px; margin-right: 10px;" })%>
    </div>   
</div>

<div id="bulk-dialog" style="display:none;" title="Allocate Bookings">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span><span id="actionTitle">Are you sure you want to allocate these bookings?</span></p>
</div>
<%} %>


</asp:Content>



