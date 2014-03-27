<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Booking.ViewModels.BookingViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.Booking.Id) + " Booking";
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%=Page.Title %></h2>
  	
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-booking-form")%>
	

            <div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
                <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
                    <li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Details</a></li>
                    <% if (!Model.IsCreate())
                       { %>          
                    
                    <%} %>
                </ul>

                <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="booking">
                    <% using (var form = Html.BeginForm("Edit", "Home", new { propertyInfoId = Model.Booking.PropertyInfo.Id},  FormMethod.Post, new { id = "edit-booking-form" }))
                    { %>           
                        <%= Html.AntiForgeryToken() %>
                        <%= Html.HiddenFor(model => model.Booking.RowVersion)%>
                        <%= Html.Hidden("Booking.Zone.Id", Model.Booking.Zone.Id) %>

                    <% Html.RenderAction("Details", "Contact", new { area = "PropertyInfo", id= Model.Booking.PropertyInfo.Id }); %>
                    <div class="left">
                        <div class="row">
                            <%= Html.LabelFor(model => model.Booking.Technician)%>
                            <%= Html.DropDownList("Booking.Technician.Id", Model.Technicians, "-- Unallocated --")%>
                        </div>   
                        <div class="row">
                            <%= Html.LabelFor(model => model.Booking.Date)%>
                            <%= Html.TextBox("Booking.Date", StringFormatter.LocalDate(Model.Booking.Date), new { @class = "datepicker" }) %>
                            <%= Html.RequiredFieldIndicator() %>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => model.Booking.Time)%>
                            <%= Html.TextBox("Booking.Time", StringFormatter.LocalTime(Model.Booking.Time), new { style = "width: 125px;" })%>
                        </div>
                        <div class="row">
                            <%= Html.LabelFor(model => model.Booking.Duration)%>
                            <%= Html.DropDownList("Booking.Duration", Model.Durations, new { style = "width: 125px;" })%>
                        </div>   
                    </div>
                    <div class="right">
                        <div class="row">
                            <%=Html.LabelFor(model=>model.Booking.KeyNumber) %>
                             <%= Html.TextBox("Booking.KeyNumber")%>
	                        
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => Model.Booking.Notes)%>
                            <%= Html.TextAreaFor(model => Model.Booking.Notes)%>
                        </div>
                    </div>
                    <div class="clear"></div>
                    <div class="buttons">
                        <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                        <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                        <input type="button" name="CancelButton" onclick="javascript:window.close();" value="Cancel" class="button ui-corner-all ui-state-default " />
                    </div>
                    <% } %>
                    <% Html.RenderAction("Schedule", "Home", new { area = "Booking", bookingId = Model.Booking.Id, propertyInfoId = Model.Booking.PropertyInfo.Id }); %>
                </div>
           </div>

           <script type="text/javascript">

               $().ready(function () {
                   //init('#booking');
               });

        </script>
</asp:Content>


