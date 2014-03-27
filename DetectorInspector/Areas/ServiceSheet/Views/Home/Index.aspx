<%@ Page Title="Service Sheets Management" Language="C#" MasterPageFile="~/Views/Shared/WideScreen.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.ServiceSheet.ViewModels.ServiceSheetSearchViewModel>" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
<% if (TempData.ContainsKey("RefreshGrid"))
   { %>
   <script type="text/javascript">
       if (window.opener && window.opener.opener && window.opener.opener.refreshGrid) {
           window.opener.opener.refreshGrid();
       }
   </script>
<% } %>
<% if (TempData.ContainsKey("DialogValue"))
   { %>
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
	<h2>Service Sheets Management</h2>

	<div class="row">
		<label for="BookingDate" style="width: 95px;">Booking Date</label>
		<%= Html.TextBox("BookingDate", StringFormatter.LocalDate(Model.BookingDate), new { @class = "datepicker textbox", style = "width: 125px;margin-right: 10px; " })%>
		<input type="button" onclick="loadBookings();" value="Refresh"  class="button ui-corner-all ui-state-default" />
	</div>

	<div class="clear"></div>

	<div class="left" >
		<div class="row">
        	<input type="checkbox" id="Check.All" name="Check_All" onClick="checkAll('selectedRow', null, this.checked); var count = getPropertyCount();updatePropertyCounter(count);" style="padding-bottom: 0px; margin-left: 15px;" />
			<label for="Check.All">Check All Services (<span id="property-count">0</span> selected)</label>
		</div>
	</div>

	<div class="clear"></div>
	<div id="placeholder"></div>
	<div class="clear"></div>
</fieldset>

<table id="service-sheet-list"></table>
<div id="pager"></div>

<script type="text/javascript">

    var previousRow = null;

    $().ready(function () {
        $('#dialog').dialog({
            modal: true,
            autoOpen: false
        });
        reloadGrid();
    });

	function loadBookings() {
		var bookingDate = $('#BookingDate').val();
		var grid = $('#service-sheet-list');
        
        grid.jqGrid("setGridParam", { postData: null });
        grid.jqGrid("setGridParam", {
            postData: {
                BookingDate: bookingDate
            }
        });

        grid.trigger("reloadGrid");

    }

    function refreshGrid() {
        loadBookings();
    }

    function reloadGrid() {

        var bookingDate = $('#BookingDate').val();
        var grid = $('#service-sheet-list');
        

        grid.jqGrid({
            width: '1591',
            height: '1000',
            url: '<%= Url.Action("GetServiceSheetsForDate", "Home", new { area = "ServiceSheet", BookingDate="_BOOKINGDATE_" }) %>'.replace(/_BOOKINGDATE_/g, escape(bookingDate)),
            dataType: 'json',
            colNames: ['', '', 'Id', 'RowVersion', 'Unit', 'House', 'Street', 'Suburb', 'State', 'PCode', 'TechnicianId', 'Technician', 'Key Number', 'Time', 'Booking Date', 'Key/Time', 'Notes', '', '', '', '', ''],
            colModel: [
                { name: 'selectLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'id', index: 'Id', key: true, hidden: true, width: 100 },
                { name: 'propertyNumber', index: 'PropertyInfo.PropertyNumber', hidden: false, width: '60px', align: 'left', sortable: true, sorttype: 'int' },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                { name: 'unitShopNumber', index: 'PropertyInfo.UnitShopNumber', hidden: false, width: '60px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'streetNumber', index: 'PropertyInfo.StreetNumber', hidden: false, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'streetName', index: 'PropertyInfo.StreetName', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'suburb', index: 'PropertyInfo.Suburb', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'state', index: 'State.Name', hidden: false, width: '70px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'postCode', index: 'PropertyInfo.PostCode', hidden: false, width: '75px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'technicianId', index: 'TechnicanId', hidden: true, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'technicianName', index: 'Technican.Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'keyNumber', index: 'Booking.KeyNumber', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'time', index: 'Time', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'bookingDate', index: 'BookingDate', hidden: false, width: '100px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'keyTime', index: 'Time', hidden: false, width: '160px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'notes', index: 'Booking.Notes', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'hasServiceSheet', index: 'HasServiceSheet', hidden: true },
                { name: 'contactNotes', index: 'PropertyInfo.ContactNotes', hidden: true },
                { name: 'bookingLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false },
            ],
            sortname: 'BookingDate',
            sortorder: 'asc',
            pager: '#pager',
            pagingMode: 'scroll',

            ondblClickRow: function (id) {
                var grid = $('#slot0_TotalServices');
                var rowData = slotGrid.getRowData(id);
                if (rowData.technicianId != '') {
                    openBooking(id, undefined, true);
                }
            },

            onRightClickRow: function (rowid, iRow, iCol, e) {
                var grid = $('#service-sheet-list');
                
                if (previousRow == null) {
                    previousRow = iRow;
                } else {
                    if (iRow < previousRow) {
                        var swapRow = previousRow;
                        previousRow = iRow;
                        iRow = swapRow;
                    }

                    var dataIds = grid.getDataIDs();
                    for (var i = previousRow; i <= iRow; i++) {
                        grid.setRowData(dataIds[i], {
                            selectLink: '<input type="checkbox" name="selectedRow" checked="checked" value="' + dataIds[i] + '" onClick="var count = getPropertyCount();updatePropertyCounter(count);">',
                        });
                    }



                    previousRow = null;

                }

                updateCounter();

            },

            loadComplete: function () {

                var grid = $('#service-sheet-list');
                var dataIds = grid.getDataIDs();

                for (var i = 0; i < dataIds.length; i++) {
                    var rowData = grid.getRowData(dataIds[i]);

                    grid.setRowData(rowData.id, {
                        selectLink: '<input type="checkbox" name="selectedRow" value="' + rowData.id + '" onClick="var count = getPropertyCount();updatePropertyCounter(count);">',
                        bookingLink: '<a href="#" onclick="openBooking(' + rowData.id + ', ' + rowData.propertyInfoId + ', false);return false;" class="button-edit">Re-Book</a>',
                        editLink: '<a href="#" onclick="openBooking(' + rowData.id + ', ' + rowData.propertyInfoId + ', true);return false;" class="button-edit">Edit</a>',
                        deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Cancel</a>'
                    });

                    // setCounter(rowData, 0);

                }

                var count = getPropertyCount();
                updatePropertyCounter(count);
                //                 var rowCount = dataIds.length;
                //                 var height = (rowCount * 23) + 5;
                //                 slotGrid.setGridHeight(height);
            }
        });

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

//    function initSetup() {
//        var bookingDate = $('#BookingDate').val();
//        setSheet(bookingDate,0);
//        setSlot(bookingDate, 'Total Services',0, 0, false);
//    }

	
	
//    function refreshGrid() {
//        refreshBookings(false);
//    }

    function refreshBookings(startup) {
        if (startup) {
            initSetup();
        } else {
            setCounterValue(0);
            loadBookings();
            updatePropertyCounter(0);
            checkAll('Check_All', null, false);
        }
    }
	
//    function setSheet(name, index)
//    {
//        var placeHolder = $('#placeholder');
//        placeHolder.append('<div id="source' + index + '"></div>');
//    }



//    function setSlot(bookingDate, caption, index, row_id, isHidden)
//    {
//         var row_name = findRowName(caption);
//         var time = caption;
//         
//         if(row_id < 1)
//         {
//            time = null;
//        }        

//         $("#source" + index).append("<div style='padding: 4px; border: 1px #CCCCCC solid;margin: 0px 0px 1px 0px; background-color: #EEEEEE;'><div id='toggle" + index + "_" + row_name + "' style='margin: 0px 5px 0px 0px; width: 120px;'>" + caption + "&nbsp;(<span id='count" + index + "_" + row_name + "'>0</span>)</div><div id='area" + index + "_" + row_name + "' style='margin: 5px 0px 0px 0px;'><table id='slot" + index + "_" + row_name + "'></table><div id='pager'></div></div><div class='clear'></div></div>");
//         var slotGrid = $('#slot' + index + '_' + row_name);
//         

//         slotGrid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

//        if(isHidden)
//        {
//            $("#area"+ index + "_" + row_name).hide();
//        }

//        $("#toggle" + index + "_" + row_name).click(function ()
//        {
//            $("#area" + index + "_" + row_name).slideToggle(600);
//        });
//    }

    function confirmDelete(id, name, rowVersion) {
        $('#deleteTitle').text(unescape(name));
        var deleteDialog = $('#dialog');
        var grid = $('#service-sheet-list');
        var updateContactNotes = $('#UpdateContactNotes');
        var rowData = grid.getRowData(id);

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
                                grid.setCell(id, 'contactNotes', updateContactNotes, null, '');
                                loadBookings();
                                showInfoMessage('Booking cancelled', result.message);
                            }
                        }
                    });
                    $(this).dialog('close');
                }
            });
        deleteDialog.dialog('open');
    }

//    function findRowName(caption)
//    {
//        return caption.replace(/:/g, '').replace(/ /g, '');
//    }

//    function findGrid(item, index)
//    {
//        var row_name = 'TotalServices';
//        return $('#slot' + index + '_' + row_name);
//    }

//    function refreshCounter(index, row_name)
//    {
//        $('#count' + index + '_' + row_name).html('0');
//    }

//    function setCounter(item, index)
//    {
//        var row_name = 'TotalServices';
//        var counter = $('#count' + index + '_' + row_name);
//        var count = parseInt(counter.html());
//        count++;
//        counter.html(count.toString());
//    }

//    function setCounterValue(value) {
//        var counter = $('#count0_TotalServices');
//        counter.html(value);
//    }
	 
</script>
 <%

	}
%>

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

</asp:Content>


