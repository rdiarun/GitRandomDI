<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.ServiceSheet.ViewModels.ElectricalJobViewModel>" %>

<div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab" style="padding: 0px 0px 0px 0px">
    <div class="full">
        <table border="0" cellpadding="1" cellspacing="0" class="service-sheet">
            <tr>
                <th nowrap="nowrap"><label for="ServiceSheetItem_Location" style="width: 125px;">Location</label></th>
                <th nowrap="nowrap"><label for="ServiceSheetItem_DetectorType_Id" style="width: 115px;">Detector Type</label></th>
                <th nowrap="nowrap"><label for="ServiceSheetItem_Manufacturer" style="width: 120px;">Manufacturer</label></th>
                <th nowrap="nowrap"><label for="ServiceSheetItem_ExpiryYear" style="width: 80px;">Expiry Year</label></th>
                <th nowrap="nowrap"><label for="ServiceSheetItem_NewExpiryYear" style="width: 80px;">New Expiry Year</label></th>
                <th nowrap="nowrap" style="padding:0 23px 0 23px"><%=Html.Image("position", "~/Content/Images/position.png", "Repositioned", "Repositioned", null)%></th>
                <th nowrap="nowrap"><%=Html.Image("battery", "~/Content/Images/battery.png", "Battery Replaced", "Battery Replaced", null)%></th>
                <th nowrap="nowrap"><%=Html.Image("clean", "~/Content/Images/clean.png", "Cleaned", "Cleaned", null)%></th>
                <th nowrap="nowrap"><%=Html.Image("sticker", "~/Content/Images/sticker.png", "Sticker Applied", "Sticker Applied", null)%></th>
                <th nowrap="nowrap"><%=Html.Image("sticker", "~/Content/Images/decibel.png", "Decibel Test", "Decibel Test", null)%></th>
                <th nowrap="nowrap" style="padding:0 0px 0 23px"><%=Html.Image("electrician", "~/Content/Images/electrical.png", "Electrician Replaced", "Electrician Replaced", null)%></th>
                <th nowrap="nowrap" style="padding:0 0px 0 23px"><%=Html.Image("optional", "~/Content/Images/optional.png", "Not Required", "Not Required", null)%></th>
                <th nowrap="nowrap" style="padding:0 0px 0 23px">
                    <%=Html.Image("problem", "~/Content/Images/problem.png", "240volt Problem", "240volt Problem", null)%>
                    <%=Html.Hidden("ServiceSheetItem.Count", Model.ServiceSheet.ActiveItems.Count()) %>
                </th>
            </tr>
        
        <% 
            var counter = 0;
            foreach(ServiceSheetItem serviceSheetItem in Model.ServiceSheet.ActiveItems)
            {
            %>
            <tr>
                <td nowrap="nowrap">
                    <%= Html.Hidden(string.Format("ServiceSheetItem.Id.{0}", counter), serviceSheetItem.Id)%>
	                <%= Html.TextBox(string.Format("ServiceSheetItem.Location.{0}", counter), serviceSheetItem.Location, new { maxlength = 100, @class = "textbox",style="width: 120px;" })%>
                </td>
	            <td nowrap="nowrap"><%= Html.DropDownList(string.Format("ServiceSheetItem.DetectorType.Id.{0}", counter), new SelectList(Model.DetectorTypes, "Id", "Name", serviceSheetItem.DetectorType!=null?serviceSheetItem.DetectorType.Id.ToString():string.Empty), "-- Please Select --", new { style = "width: 120px;", @class= "detectorVal" })%></td>
                <td nowrap="nowrap"><%= Html.TextBox(string.Format("ServiceSheetItem.Manufacturer.{0}", counter), serviceSheetItem.Manufacturer, new { maxlength = 50, @class = "textbox", style = "width: 120px;" })%></td>
                <td nowrap="nowrap"><%= Html.TextBox(string.Format("ServiceSheetItem.ExpiryYear.{0}", counter), serviceSheetItem.ExpiryYear, new { maxlength = 4, @class = "textbox small" })%></td>
                <td nowrap="nowrap"><%= Html.TextBox(string.Format("ServiceSheetItem.NewExpiryYear.{0}", counter), serviceSheetItem.NewExpiryYear, new { maxlength = 4, @class = "textbox small" })%></td>
                <td nowrap="nowrap" style="padding:0 23px 0 23px"><%= Html.CheckBox(string.Format("ServiceSheetItem.IsRepositioned.{0}", counter), serviceSheetItem.IsRepositioned)%></td>
                <td nowrap="nowrap"><%= Html.CheckBox(string.Format("ServiceSheetItem.IsBatteryReplaced.{0}", counter), serviceSheetItem.IsBatteryReplaced)%></td>
                <td nowrap="nowrap"><%= Html.CheckBox(string.Format("ServiceSheetItem.IsCleaned.{0}", counter), serviceSheetItem.IsCleaned)%></td>
                <td nowrap="nowrap"><%= Html.CheckBox(string.Format("ServiceSheetItem.HasSticker.{0}", counter), serviceSheetItem.HasSticker)%></td>
                <td nowrap="nowrap"><%= Html.CheckBox(string.Format("ServiceSheetItem.IsDecibelTested.{0}", counter), serviceSheetItem.IsDecibelTested)%></td>
                <td nowrap="nowrap" style="padding:0 0px 0 23px"><%= Html.CheckBox(string.Format("ServiceSheetItem.IsReplacedByElectrician.{0}", counter), serviceSheetItem.IsReplacedByElectrician, null)%></td>
                <td nowrap="nowrap" style="padding:0 0px 0 23px"><%= Html.CheckBox(string.Format("ServiceSheetItem.IsOptional.{0}", counter), serviceSheetItem.IsOptional, null)%></td>
                <td nowrap="nowrap" style="padding:0 0px 0 23px"><%= Html.CheckBox(string.Format("ServiceSheetItem.HasProblem.{0}", counter), serviceSheetItem.HasProblem, null)%></td>
            </tr>
                <%
                counter++;
            } %>
        </table>
    </div>
</div>        	


