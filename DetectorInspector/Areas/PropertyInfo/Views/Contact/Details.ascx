<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>
    <fieldset style="width: 847px;">
        <legend>Property Contact Details: <%=Model.PropertyInfo.ToString() %></legend>
        <div style="width: 275px; margin-left: 5px;" class="tenant-field">
            <div style="width: 120px; font-weight:bold;" class="tenant-field"><%=Model.PropertyInfo.OccupantName %></div>
            <div style="width: 130px; " class="tenant-field">
                <%
                    foreach (var contactInfo in Model.PropertyInfo.ActiveContactEntries)
                    {
                %>
                        <div><span style="width: 55px;" class="tenant-field"><%=contactInfo.ContactNumberType.Name %>:</span><%=contactInfo.ContactNumber %></div>
                <%
                    }
                    %>
            </div>
        </div>
    </fieldset>
    <div class="clear"></div>

