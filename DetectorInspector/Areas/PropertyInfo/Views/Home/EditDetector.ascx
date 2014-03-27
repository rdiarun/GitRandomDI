<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.PropertyInfo.ViewModels.DetectorViewModel>" %>
<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-detector-form")%>
	
<% using (var form = Html.BeginForm("Edit", "Detector", new { id = Model.Detector.Id, propertyInfoId = Model.PropertyInfo.Id }, FormMethod.Post, new { id = "edit-detector-form" }))
    { %>           
        <%= Html.AntiForgeryToken() %>
        <%= Html.HiddenFor(model => model.Detector.RowVersion)%>
        <% if (TempData["IsValid"]!=null)
           {
               Response.Write(Html.Hidden("IsValid", true));
               TempData.Remove("IsValid");
           }
        %>
        <div class="clear"></div>
        <h3><%=Html.GetCreateEditText(Model.Detector.Id) + " Detector" %></h3>
        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab" style="padding: 0px 0px 0px 0px">
            <div class="full">       
                <div class="row" style="margin-bottom: 0px;">
                    <label for="Detector_Location" style="width: 215px;">Location</label>
                    <label for="Detector_DetectorType_Id" style="width: 205px;">Detector Type</label>
                    <label for="Detector_Manufacturer" style="width: 205px;">Manufacturer</label>
                    <label for="Detector_ExpiryYear" style="width: 90px;">Expiry Year</label>
                    <label for="Detector_IsOptional" style="width: 90px;">Not Required</label>
                </div>    
                <div class="row">
	                <%= Html.TextBoxFor(model => model.Detector.Location, new { maxlength = 100, @class = "textbox", style="width: 210px;" })%>
	                <%= Html.DropDownList("Detector.DetectorType.Id", Model.DetectorTypes, "-- Please Select --", new { style = "width: 210px;" })%>
                    <%= Html.TextBoxFor(model => model.Detector.Manufacturer, new { maxlength = 50, @class = "textbox", style = "width: 205px;" })%>
                    <%= Html.TextBoxFor(model => model.Detector.ExpiryYear, new { maxlength = 4, @class = "textbox small", style = "width: 85px;" })%>
                    <%= Html.CheckBoxFor(model => model.Detector.IsOptional)%>
                </div>    
            </div>
        </div>
        <div class="buttons"  style="margin-top: 0px;">
            <input type="button" name="ApplyButton" value="Save"   class="button ui-corner-all ui-state-default " onclick="javascript:saveDetector(<%=Model.Detector.Id %>);return false;" />
            <input type="button" onclick="javascript:editDetector(0);return false;" value="Cancel"  class="button ui-corner-all ui-state-default " />
        </div>
<% } %>
    
