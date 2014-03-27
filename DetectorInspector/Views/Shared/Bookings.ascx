<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl<DetectorInspector.Areas.Technician.ViewModels.BookingsViewModel>" %>
<% if(Model.Bookings.Count() > 0){ 
%>
    <div class="print-row">
        <div class="print-header" style="width: 100px;">Agency</div>
        <div class="print-header" style="width: 30px;">Id</div>
        <div class="print-header" style="width: 210px;">Property</div>
        <div class="print-header" style="width: 140px;">Tenant</div>
        <div class="print-header" style="width: 40px;">Ladder</div>
        <div class="print-header" style="width: 100px;">Time</div>
        <div class="print-header" style="width: 40px;">Key</div>
        <div class="print-header" style="width: 170px;">Notes</div>
    </div>
<%
    foreach(var booking in Model.Bookings){ %>
    <div class="print-row">
        <div class="print-cell" style="width: 100px;"><%=booking.PropertyInfo.Agency.Name %>&nbsp;</div>
        <div class="print-cell" style="width: 30px;"><%=booking.PropertyInfo.PropertyNumber %>&nbsp;</div>
        <div class="print-cell" style="width: 210px;"><%=booking.PropertyInfo.ToString() %>&nbsp;</div>
        <div class="print-cell" style="width: 140px;"><%=String.Join("<br />", booking.PropertyInfo.OccupantName, booking.PropertyInfo.GetTenantPropertyPhones())%></div>
        <div class="print-cell" style="width: 40px;"><%=StringFormatter.BooleanToYesNo(booking.PropertyInfo.HasLargeLadder) %>&nbsp;</div>
		<div class="print-cell" style="width: 100px;"><%
		if (booking.Time != null)
		{%>
			<%=String.Format("{0}-{1}", StringFormatter.LocalTime(booking.Time), StringFormatter.LocalTime(booking.Time.Value.AddMinutes(booking.Duration))) %>
		<%}%>
		&nbsp;</div>
        <div class="print-cell" style="width: 40px;"><%=booking.KeyNumber %>&nbsp;</div>
        <div class="print-cell" style="width: 170px;"><%=booking.Notes %>&nbsp;</div>
    </div>
    <%
    }
   } else {%>
    <div style="padding: 10px; font-weight: bold;">You have no bookings on this date</div>
   <% } %>