<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.Booking.ViewModels.BookingScheduleViewModel>" %>

<div class="clear spacer"></div>
<div class="row">
	<label for="BookingDate" style="width: 95px; margin-left: 10px;">Booking Date</label>
	<%= Html.TextBox("BookingDate", StringFormatter.LocalDate(Model.BookingDate), new { @class = "datepicker textbox", style = "width: 125px;margin-right: 10px; " })%>
	<input type="button" onclick="refreshBookings(false);" value="Load"  class="button ui-corner-all ui-state-default" />
</div>
<div class="clear"></div>
<div id="placeholder"></div>
<div class="clear"></div>


<% using (Html.BeginForm("Delete", "Home", FormMethod.Post, new { id = "delete-form" }))
   {%>
	<%= Html.AntiForgeryToken()%>
	<%= Html.Hidden("RowVersion")%>
<% } %>

<script type="text/javascript">

	$().ready(function () {

		refreshBookings(true);
	});


	function getAvailableTechnician(bookingDate) {
		var returnValue = null;
		$.ajax({
			type: 'GET',
			url: '<%= Url.Action("AvailableTechnician", "TechnicianAvailability", new { area = "Technician", date="_BOOKINGDATE_" }) %>'.replace(/_BOOKINGDATE_/g, escape(bookingDate)),
			success: function (result) {
				returnValue = result;
			},
			error: function (result) {
				showInfoMessage('Failed', 'Could not load technicians');
			}
		});
		return returnValue;
	}

	function initSetup(startup) {
		var bookingDate = $('#BookingDate').val();
		var days = 7;// rjc 20130606. Jason asked for this to be reduced to 7 dats

		if (startup) {
			for (var i = 0; i < days; i++) {
				var thisDate = bookingDate.fromDDMMYYYY();
				thisDate.addDays(i);
				setDate(thisDate.toDDMMYYYY(), i);
				setSlot(thisDate.toDDMMYYYY(), 'Appointments', i, 1, false);
				setSlot(thisDate.toDDMMYYYY(), 'Key Entry', i, 0, true);
			}
			
		}
		else {
			for (var i = 0; i < days; i++) {
				var thisDate = bookingDate.fromDDMMYYYY();
				thisDate.addDays(i);

				refreshSlot(thisDate.toDDMMYYYY(), 'Appointments', i, 1, false);
				refreshSlot(thisDate.toDDMMYYYY(), 'Key Entry', i, 0, true);
			}
			
		}
	}

	function refreshSlot(bookingDate, caption, index, row_id, isHidden)
	{
		 var row_name = findRowName(caption);
		 var time = caption;
		 var availableTechnician = null;
		 
		 availableTechnician = getAvailableTechnician(bookingDate);
		 refreshCounter(index, row_name, bookingDate, availableTechnician);
		 
		 var slotGrid = $('#slot' + index + '_' + row_name);
		 var dataIds = slotGrid.getDataIDs();

		 slotGrid.setGridHeight(0);

		for (var i = 0; i < dataIds.length; i++) {
			slotGrid.delRowData(dataIds[i]);
		}

		if (isHidden) {
			$("#area" + index + "_" + row_name).hide();
		}
	}

	var updateGridHeight = function ($gridElement) {
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
			 url: '<%= Url.Action("GetBookingsForDateRange", "Home", new { area = "Booking", BookingDate="_BOOKINGDATE_" }) %>'.replace(/_BOOKINGDATE_/g, escape(bookingDate)),
			 dataType: 'json',
			 success: function (result) {
				 $.each(result.items, function (i, item) {
					 var grid = findGrid(item);
					 addGridRow(grid, item);
		        });

		        $('#placeholder .ui-jqgrid-btable').each(function () {
		            updateGridHeight($(this));
		        });
			 },
			 error: function (result) {
				 showInfoMessage('Failed', 'Could not load bookings');
			 }
		 });
	 }    

	 function refreshBookings(startup) {
	     initSetup(startup);
	     if (!startup)
	     {
	         loadBookings();
	     }
	 }
	
	function setDate(name, index) {
		var placeHolder = $('#placeholder');    
		placeHolder.append('<fieldset style="width: 847px; float:left; margin: 0px 5px 0px 0px;"><legend id="legend-' + index + '">' + name + '</legend><div id="technician-' + index + '"></div><div id="source' + index + '"></div></fieldset><div class="clear"></div>');
	}

	function setSlot(bookingDate, caption, index, row_id, isHidden)
	{
		 var row_name = findRowName(caption);
		 var time = caption;
		 var availableTechnician = null;

		 if (row_id < 1) {
			 time = null;
		 }
		 else {
			 availableTechnician = getAvailableTechnician(bookingDate);
			 setTechnician(index, availableTechnician);
		 }

		 $("#source" + index).append("<div style='padding: 4px; border: 1px #CCCCCC solid;margin: 0px 0px 1px 0px; background-color: #EEEEEE;'><div id='toggle" + index + "_" + row_name + "' style='margin: 0px 5px 0px 0px; width: 90px;'>" + caption + "&nbsp;(<span id='count" + index + "_" + row_name + "'>0</span>)</div><div id='area" + index + "_" + row_name + "' style='margin: 5px 0px 0px 0px;'><table id='slot" + index + "_" + row_name + "'></table></div><div class='clear'></div></div>");
		 var slotGrid = $('#slot' + index + '_' + row_name);
		 slotGrid.jqGrid({
			width: '834',
			height: '0',
			datatype: 'clientSide',
			colNames: ['', 'RowVersion', 'Unit', 'House', 'Street', 'Suburb', 'State', 'PCode', 'Key Number', 'Tenant', 'Contact Number', 'Problem', 'Large Ladder', 'Time',  'Key/Time'],
			colModel: [
				{ name: 'id', index: 'Id', key: true, hidden: true, width: 100 },
				{ name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
				{ name: 'unitShopNumber', index: 'UnitShopNumber', hidden: false, width: '60px', align: 'left', sortable: true, sorttype: 'text' },
				{ name: 'streetNumber', index: 'StreetNumber', hidden: false, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
				{ name: 'streetName', index: 'StreetName', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
				{ name: 'suburb', index: 'Suburb', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
				{ name: 'state', index: 'State.Name', hidden: false, width: '70px', align: 'center', sortable: true, sorttype: 'text' },
				{ name: 'postCode', index: 'PostCode', hidden: false, width: '75px', align: 'center', sortable: true, sorttype: 'text' },
				{ name: 'keyNumber', index: 'KeyNumber', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
				{ name: 'tenantName', index: 'TenantName', hidden: false, width: 200, align: 'left', sortable: false, sorttype: 'text' },
				{ name: 'tenantContactNumber', index: 'TenantContactNumber', hidden: false, width: 200, align: 'left', sortable: false, sorttype: 'text' },
				{ name: 'hasProblem', index: 'HasProblem', hidden: true },
				{ name: 'hasLargeLadder', index: 'HasLargeLadder', hidden: true },
				{ name: 'time', index: 'Time', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
				{ name: 'keyTime', index: 'Time', hidden: false, width: '160px', align: 'left', sortable: true, sorttype: 'text' }
			]
		});

		if(isHidden)
		{
			$("#area"+ index + "_" + row_name).hide();
		}

		$("#toggle" + index + "_" + row_name).click(function ()
		{
			$("#area" + index + "_" + row_name).slideToggle(0, function () {
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

	function dateDiff1(startDate, endDate) {
		return ((endDate.fromDDMMYYYY().getTime() - startDate.fromDDMMYYYY().getTime()) / (1000 * 60 * 60 * 24));
	} 

	function findIndex(item, date) {
		var index = 0;
		var bookingDate = date;
		var itemDate = item.bookingDate;
		index = dateDiff1(bookingDate, itemDate);
		return index;
	}

	function findGrid(item) {
		
		var index = findIndex(item, $('#BookingDate').val());


		var row_name = 'KeyEntry';


		if(item.bookingTime != '')
		{
			//row_name = findRowName(item.bookingTime);
			row_name = findRowName('Appointments');
		}

		return $('#slot' + index + '_' + row_name);

	}

	function setTechnician(index, technicianInfo) {
		if (technicianInfo != null) {
			$('#technician-' + index).html('<fieldset style="width: 837px;"><legend>Available Technicians</legend>' + technicianInfo + '</fieldset><div class="spacer clear"></div>');
			//$('#technician-' + index).html(technicianInfo + '<div class="spacer clear"></div>');
		}
		else {
			$('#technician-' + index).html('');
		}
	}

	function refreshCounter(index, row_name, caption, technicianInfo) {
		$('#legend-' + index).html(caption);
		setTechnician(index, technicianInfo);
		$('#count' + index + '_' + row_name).html('0');
	}

	function setCounter(item)
	{
		var index = findIndex(item, $('#BookingDate').val());
		var row_name = 'KeyEntry';

		if(item.bookingTime != '')
		{
			//row_name = findRowName(item.bookingTime);
			row_name = findRowName('Appointments');
		}

		var counter = $('#count' + index + '_' + row_name);
		var count = parseInt(counter.html());
		count++;
		counter.html(count.toString());
	}

	function addGridRow(grid, item)
	{
		grid.addRowData(item.id, { id: item.id,
							propertyInfoId: item.propertyInfoId,
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
							duration: item.duration,
							agencyName: item.agencyName,
							propertyManager: item.propertyManager,
							postCode: item.postCode,
							notes: item.notes,
							keyTime: item.keyTime  });


		setCounter(item);
		
	}

</script>

