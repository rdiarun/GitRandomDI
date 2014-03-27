<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl<DetectorInspector.ViewModels.UserProfileViewModel>" %>

<% if (Model.Technician != null)
   { %>
<div class="clear spacer"></div>
<div class="row">
    <label for="BookingDate" style="width: 95px; margin-left: 10px;">Booking Date</label>
	<%= Html.TextBox("BookingDate", StringFormatter.LocalDate(DateTime.Today), new { @class = "datepicker textbox", style = "width: 125px;margin-right: 10px; " })%>
    <input type="button" onclick="loadBookings();" value="Refresh"  class="button ui-corner-all ui-state-default" />
</div>
<div class="clear"></div>
<div id="placeholder"></div>
<div class="clear"></div>



<script type="text/javascript">


    $().ready(function () {

        loadBookings();

    });



    function loadBookings() {
        var bookingDate = $('#BookingDate').val();

        $.ajax({
            type: 'GET',
            url: '<%= Url.Action("Bookings", "Home", new { area = "Technician", technicianId=Model.Technician.Id, date="_DATE_" }) %>'.replace(/_DATE_/g, bookingDate),
            success: function (result) {
                var placeHolder = $('#placeholder');
                placeHolder.html(result);
            }
        });
    }
    </script>


<% } %>
