<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.Technician.ViewModels.TechnicianAvailabilityViewModel>" %>
<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-technician-availability-form")%>
	
<% using (var form = Html.BeginForm("Edit", "TechnicianAvailability", new { id = Model.TechnicianAvailability.Id, technicianId = Model.Technician.Id }, FormMethod.Post, new { id = "edit-technician-availability-form" }))
    { %>           
        <%= Html.AntiForgeryToken() %>
        <%= Html.HiddenFor(model => model.TechnicianAvailability.RowVersion)%>
        <% if (TempData["IsValid"]!=null)
           {
               Response.Write(Html.Hidden("IsValid", true));
               TempData.Remove("IsValid");
           }
        %>
        <div class="clear"></div>
        <h3><%=Html.GetCreateEditText(Model.TechnicianAvailability.Id) + " Availability" %></h3>
        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
            <div class="left">       
                <div class="row">
                    <%= Html.LabelFor(model => model.TechnicianAvailability.IsInclusion)%>
                    <%= Html.DropDownListFor(model => model.TechnicianAvailability.IsInclusion, Html.GetYesNoSelectListItems(), "-- Please Select --", new { style = "width: 125px;" })%>
                </div>       
                <div class="row">
                    <%= Html.LabelFor(model => model.TechnicianAvailability.StartDate)%>
                    <%= Html.TextBox("TechnicianAvailability.StartDate", StringFormatter.LocalDate(Model.TechnicianAvailability.StartDate), new { maxlength = 10, @class = "datepicker" })%>
                    <%= Html.RequiredFieldIndicator() %>
                </div>    
                <div class="row">
                    <%= Html.LabelFor(model => model.TechnicianAvailability.StartTime)%>
                    <%= Html.TextBox("TechnicianAvailability.StartTime", StringFormatter.LocalTime(Model.TechnicianAvailability.StartTime), new { style = "width: 125px;" })%>
                </div>            
                <div class="row">
                    <%= Html.LabelFor(model => model.TechnicianAvailability.EndDate)%>
                    <%= Html.TextBox("TechnicianAvailability.EndDate", StringFormatter.LocalDate(Model.TechnicianAvailability.EndDate), new { maxlength = 10, @class = "datepicker" })%>
                </div>    
                <div class="row">
                    <%= Html.LabelFor(model => model.TechnicianAvailability.EndTime)%>
                    <%= Html.TextBox("TechnicianAvailability.EndTime", StringFormatter.LocalTime(Model.TechnicianAvailability.EndTime), new { style = "width: 125px;" })%>
                </div>    
            </div>
        </div>
        <div class="buttons">
            <input type="button" name="ApplyButton" value="Save"   class="button ui-corner-all ui-state-default " onclick="javascript:saveTechnicianAvailability(<%=Model.TechnicianAvailability.Id %>);return false;" />
            <input type="button" onclick="javascript:editTechnicianAvailability(0);return false;" value="Cancel"  class="button ui-corner-all ui-state-default " />
        </div>
<% } %>
    
