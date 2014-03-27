<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.Technician.ViewModels.AvailableTechnicianViewModel>" %>

<%
    if(Model.Technicians.Count() > 0)
    {
        foreach (var technician in Model.Technicians)
        {
    %>
            <div style="width: 130px; margin-left: 5px;" class="tenant-field">
                <div style="width: 120px; font-weight:bold;" class="technician-field"><%=technician.Name %></div>
                <% var currentAvailability = (from t in technician.CurrentAvailability where t.StartDate <= Model.Date && t.EndDate >= Model.Date select t);
                   if (currentAvailability.Count() > 0)
                   {
                %>
                <div style="width: 120px; " class="technician-field">
                    <div><span style="width: 120px; font-style:italic;" class="technician-field">Special Conditions:</span></div>
                    <%
                        foreach (var availability in currentAvailability)
                        {
                            var color = string.Format(availability.IsInclusion ? "#33CC33" : "#CC3333");
                            if (availability.StartDate.Equals(availability.EndDate))
                            {
                                if (availability.StartTime == null || availability.EndTime == null)
                                {
                    %>
                                <div><span style="width: 120px; color:<%=color%>;" class="technician-field"><%=StringFormatter.LocalDate(availability.StartDate)%></span></div>
                    <%
                                }
                                else
                                {
                     %>
                                <div><span style="width: 120px; color:<%=color%>;" class="technician-field"><%=string.Concat(StringFormatter.LocalDate(availability.StartDate), availability.StartTime != null ? ":" + StringFormatter.LocalTime(availability.StartTime) : string.Empty, availability.EndTime != null ? "-" + StringFormatter.LocalTime(availability.EndTime) : string.Empty)%></span></div>
                    <%
                                }
                            }
                            else
                            {
                                if (availability.StartTime == null || availability.EndTime == null)
                                {
                    %>
                                    <div><span style="width: 120px; color:<%=color%>;" class="technician-field"><%=string.Concat(StringFormatter.LocalDate(availability.StartDate), "-", StringFormatter.LocalDate(availability.EndDate))%></span></div>
                    <%
                                }
                                else
                                {
                    %>
                                    <div><span style="width: 120px; color:<%=color%>;" class="technician-field"><%=string.Concat(StringFormatter.LocalDate(availability.StartDate), availability.StartTime != null ? ":" + StringFormatter.LocalTime(availability.StartTime) : string.Empty,"-")%></span></div>
                                    <div><span style="width: 120px; color:<%=color%>;" class="technician-field"><%=string.Concat(StringFormatter.LocalDate(availability.EndDate), availability.EndTime != null ? ":" + StringFormatter.LocalTime(availability.EndTime) : string.Empty)%></span></div>
                    <%
                                }
                            }
                        }
                     %>
                </div>
                <%
                    } %>
            </div>
<%
        }
    }else{
%>
        <div style="color: #CC3333;">There are no available technicians</div>
<%  }%>
    