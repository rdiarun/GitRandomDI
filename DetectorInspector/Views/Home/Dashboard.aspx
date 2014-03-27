<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.ViewModels.UserProfileViewModel>" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div id="dashboard">
    <h2>Dashboard</h2>
        <% Html.RenderPartial("ProfileHeader"); %>
        <div class="clear spacer"></div>
        <div class="divider clear spacer"></div>
        <div class="clear spacer"></div>
    </div>
    <% if(SecurityExtensions.HasPermission(this.Context.User, Permission.AccessServiceSheets)) {%>
         
        <img src="<%= Url.Action("GetMonthlyService", "Home", new { area = "Reporting" }) %>" alt="Chart" />
   <%
        }
    %>
    <% if (SecurityExtensions.HasPermission(this.Context.User, Permission.AccessTechnicianDashboard)) { %>
    <% if (Model.Technician != null)
       { %>
        <div id="charts">
      <%--      <div style="display:inline-block; float:left;"><img src="<%= Url.Action("GetServiceByZone", "Home", new { area = "Reporting", monthToAdd = -7, technicianId = Model.Technician.Id  }) %>" alt="Chart" /></div>
            <div style="display:inline-block; float:left;"><img src="<%= Url.Action("GetServiceByZone", "Home", new { area = "Reporting", monthToAdd = -8, technicianId =  Model.Technician.Id  }) %>" alt="Chart" /></div>
            <div style="display:inline-block; float:left;"><img src="<%= Url.Action("GetServiceByZone", "Home", new { area = "Reporting", monthToAdd = -9, technicianId =  Model.Technician.Id  }) %>" alt="Chart" /></div>
       --%>

                  <div style="display:inline-block; float:left;"><img src="<%= Url.Action("GetServiceByZone", "Home", new { area = "Reporting", monthToAdd = -7, technicianId = Model.Technician.Id  }) %>" alt="Chart" /></div>
            <div style="display:inline-block; float:left;"><img src="<%= Url.Action("GetServiceByZone", "Home", new { area = "Reporting", monthToAdd = -8, technicianId =  Model.Technician.Id  }) %>" alt="Chart" /></div>
            <div style="display:inline-block; float:left;"><img src="<%= Url.Action("GetServiceByZone", "Home", new { area = "Reporting", monthToAdd = -9, technicianId =  Model.Technician.Id  }) %>" alt="Chart" /></div>
       
        </div>
        <div class="clear spacer"></div>
        <div class="divider clear spacer"></div>
        <div class="clear spacer"></div>
        <div id="appointments">
            <% Html.RenderPartial("Appointments"); %>
        </div>
        <div class="clear spacer"></div>
        <div class="divider clear spacer"></div>
        <div class="clear spacer"></div>
        <div id="availability">
            <% Html.RenderAction("Availability", "TechnicianAvailability", new { area = "Technician", id = Model.Technician.Id }); %>
        </div>

    <% }
       else
       {%>
        <div id="charts">
           <%-- <fieldset style="float:left; width: 285px; margin-right: 10px;">
            <% Html.RenderAction("ServicesByZone", "Home", new { area = "Technician", monthToAdd = 0 }); %>
            </fieldset>
            <fieldset style="float:left; width: 285px; margin-right: 10px;">
            <% Html.RenderAction("ServicesByZone", "Home", new { area = "Technician", monthToAdd = -1 }); %>
            </fieldset>
            <fieldset style="float:left; width: 285px;">
            <% Html.RenderAction("ServicesByZone", "Home", new { area = "Technician", monthToAdd = -2}); %>
            </fieldset>--%>


             <fieldset style="float:left; width: 285px; margin-right: 10px;">
            <% Html.RenderAction("ServicesByZone", "Home", new { area = "Technician", monthToAdd = -7 }); %>
            </fieldset>
            <fieldset style="float:left; width: 285px; margin-right: 10px;">
            <% Html.RenderAction("ServicesByZone", "Home", new { area = "Technician", monthToAdd = -8 }); %>
            </fieldset>
            <fieldset style="float:left; width: 285px;">
            <% Html.RenderAction("ServicesByZone", "Home", new { area = "Technician", monthToAdd = -9}); %>
            </fieldset>


        </div>
        <div class="clear spacer"></div>
        <%
        }  
       } %>

</asp:Content>

