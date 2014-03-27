<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl<DetectorInspector.Model.Technician>" %>
<fieldset>
    <legend>Availability</legend>
    <div class="row print-row">
        <label>Currently Available on</label>
        <span class="read-only">
         <%if (!string.IsNullOrEmpty(Model.DefaultAvailability))
           {
             Response.Write(String.Join(",", Model.DefaultAvailability.Split(",".ToCharArray()).Select(d => Enum.Parse(typeof(DayOfWeek), d)).OrderBy(d => (int) d).ToArray()));  
           }      
         %>
        </span>
    </div>
    <% 
        if (Model.CurrentAvailability.Count() > 0)
        {
    %>
    <div style="width: 120px; " class="technician-field print-row">
        <div><span style="width: 120px; font-style:italic;" class="technician-field">Special Conditions:</span></div>
        <%
            // RJC 20130314. Changd line below to use Model.AvailabilityFromNowOnwards instead of Model.CurrentAvailability. To fix issue 14 on bug list
            foreach (var availability in Model.AvailabilityFromNowOnwards)
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
</fieldset>
