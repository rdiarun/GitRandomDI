<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl<DetectorInspector.Areas.Technician.ViewModels.ServicesByZoneViewModel>" %>
    <legend><%=Model.Title %></legend>
<% if(Model.Services.Count() > 0){ 
%>
        <div class="print-row">
            <div class="print-header" style="width: 110px;">Technician</div>
            <div class="print-header" style="width: 40px;">Zone 1</div>
            <div class="print-header" style="width: 40px;">Zone 2</div>
            <div class="print-header" style="width: 40px;">Zone 3</div>
        </div>
    <%
        foreach(var service in Model.Services){ %>
        <div class="print-row">
            <div class="print-cell" style="width: 110px;"><%=service.TechnicianFirstName%>&nbsp;<%=service.TechnicianLastName%></div>
            <div class="print-cell" style="width: 40px; text-align:right;"><%=service.ServicesByZone1%>&nbsp;</div>
            <div class="print-cell" style="width: 40px; text-align:right;"><%=service.ServicesByZone2%>&nbsp;</div>
            <div class="print-cell" style="width: 40px; text-align:right;"><%=service.ServicesByZone3%>&nbsp;</div>
        </div>
        <%
        }
       } else {%>
        <div style="padding: 10px; font-weight: bold;">There are no completed services</div>
       <% } %>