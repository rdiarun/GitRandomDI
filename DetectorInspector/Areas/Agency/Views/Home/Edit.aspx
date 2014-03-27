<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Agency.ViewModels.AgencyViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.Agency.Id) + " Agency";
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%=Page.Title %></h2>
  	
	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "edit-form")%>
	
    <% using (var form = Html.BeginForm("Edit", "Home", FormMethod.Post, new { id = "edit-form", enctype = "multipart/form-data" }))
       { %>           
            <%= Html.AntiForgeryToken() %>
            <%= Html.HiddenFor(model => model.Agency.RowVersion)%>

            <div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
                <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
                    <li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Details</a></li>
                    <% if (!Model.IsCreate())
                       { %>          
                    <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Property Managers", "Index", "PropertyManager", new { area = "Agency", id = Model.Agency.Id }, null)%></li>
                    <%} %>
                </ul>
            
                <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
                    <div class="left">
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.AgencyGroup)%>
                            <%= Html.DropDownList("Agency.AgencyGroup.Id", Model.AgencyGroups, "--Please select--")%>
                            <%= Html.RequiredFieldIndicator() %>
                        </div>           
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.Name)%>
                            <%= Html.TextBoxFor(model => model.Agency.Name, new { maxlength = 100, @class = "textbox" })%>
                            <%= Html.RequiredFieldIndicator() %>
                        </div>            
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.CustomerCode)%>
                            <%= Html.TextBoxFor(model => model.Agency.CustomerCode, new { maxlength = 3, @class = "textbox" })%>
                            <%= Html.RequiredFieldIndicator() %>
                        </div>            
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.ABN)%>
                            <%= Html.TextBoxFor(model => model.Agency.ABN, new { maxlength = 11, @class = "textbox" })%>
                        </div>
  
<%--                                            
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.ConsoleVersionNumber)%>
                            <%= Html.TextBoxFor(model => model.Agency.ConsoleVersionNumber, new { maxlength = 50, @class = "textbox" })%>
                        </div>   
--%>                        
                        <div class="row">
	                        <label for="Agency_ClientDatabaseSystemType_Id">Client Database System</label>
	                        <%= Html.DropDownList("Agency.ClientDatabaseSystemType.Id", Model.ClientDatabaseSystemTypes, "-- Please Select --")%>
                        </div>  
<%-- --%>

                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.ClientCreditorReference)%>
                            <%= Html.TextBoxFor(model => model.Agency.ClientCreditorReference, new { maxlength = 50, @class = "textbox" })%>
                        </div>
						
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.Discount)%>
                            <%= Html.TextBox("Agency.Discount", string.Format("{0:f2}", Model.Agency.Discount), new { @class = "textbox money" }) %>
                        </div>
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.StreetAddress)%>
                            <%= Html.TextBoxFor(model => model.Agency.StreetAddress, new { @class = "textbox" })%>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.StreetSuburb)%>
                            <%= Html.TextBoxFor(model => model.Agency.StreetSuburb, new { maxlength = 50, @class = "textbox" })%>
                        </div>    
                        <div class="row">
	                        <label for="Agency_StreetState_Id">Street State</label>
	                        <%= Html.DropDownList("Agency.StreetState.Id", Model.StreetStates, "-- Please Select --")%>
                        </div>            
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.StreetPostCode)%>
                            <%= Html.TextBoxFor(model => model.Agency.StreetPostCode, new { maxlength = 4, @class = "textbox" })%>
                        </div>    

                         <div class="row">
							<%= Html.LabelFor(model => Model.Agency.IsFixedFeeService)%>
							<%= Html.CheckBoxFor(model => model.Agency.IsFixedFeeService)%>
                         </div>
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.EntryNotificationSignoffName)%>
                            <%= Html.TextBoxFor(model => model.Agency.EntryNotificationSignoffName, new { @class = "textbox" })%>
                        </div>   
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.EntryNotificationSignoffPosition)%>
                            <%= Html.TextBoxFor(model => model.Agency.EntryNotificationSignoffPosition, new { @class = "textbox" })%>
                        </div>   
                        <div class="row">
							<%= Html.LabelFor(model => Model.Agency.UseEntryNotificationLetter)%>
							<%= Html.CheckBoxFor(model => model.Agency.UseEntryNotificationLetter)%>
                         </div>

                    </div>
                    <div class="right">
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.PostalLine1)%>
                            <%= Html.TextBoxFor(model => model.Agency.PostalLine1, new { @class = "textbox" })%>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.PostalLine2)%>
                            <%= Html.TextBoxFor(model => model.Agency.PostalLine2, new { @class = "textbox" })%>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.PostalAddress)%>
                            <%= Html.TextBoxFor(model => model.Agency.PostalAddress, new { @class = "textbox" })%>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.PostalSuburb)%>
                            <%= Html.TextBoxFor(model => model.Agency.PostalSuburb, new { maxlength = 50, @class = "textbox" })%>
                        </div>    
                        <div class="row">
	                        <label for="Agency_PostalState_Id">Postal State</label>
	                        <%= Html.DropDownList("Agency.PostalState.Id", Model.PostalStates, "-- Please Select --")%>
                        </div>            
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.PostalPostCode)%>
                            <%= Html.TextBoxFor(model => model.Agency.PostalPostCode, new { maxlength = 4, @class = "textbox" })%>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.Telephone)%>
                            <%= Html.TextBoxFor(model => model.Agency.Telephone, new { maxlength = 12, @class = "textbox" })%>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.Fax)%>
                            <%= Html.TextBoxFor(model => model.Agency.Fax, new { maxlength = 12, @class = "textbox" })%>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.Email)%>
                            <%= Html.TextBoxFor(model => model.Agency.Email, new { maxlength = 400, @class = "textbox" })%>
                        </div>
                        <div class="row">
                            <%= Html.LabelFor(model => model.Agency.Website)%>
                            <%= Html.TextBoxFor(model => model.Agency.Website, new { maxlength = 400, @class = "textbox" })%>
                        </div>        
                        <div class="row">
	                        <label for="Agency_DefaultPropertyManager_Id">Default Property Manager</label>
	                        <%= Html.DropDownList("Agency.DefaultPropertyManager.Id", Model.PropertyManagers, "-- Please Select --")%>
                        </div>  
                    </div>

                </div>
                <div style="clear:both"></div>
                 <div class="row" style="margin-left:15px;">
                    <label>Entry notification template upload</label>
                    <input type="file" name="EntryNotificationLetterFile" id="EntryNotificationLetter" />
                    <input type="submit" name="ApplyButton" value="Import & Save" onclick="javascript:return(checkForFile())" class="button ui-corner-all ui-state-default " />
                </div>
                <div class="row" style="margin-left:15px;">
                    <%  if (Model.HasEntryNotificationLetter==true) 
                        {
                            Response.Write(Html.ActionLink("Download Entry Notification", "DownLoadEntryNotification/" + Model.Agency.Id));
                        }                    
                        %>
                </div>

                <div class="buttons">
                    <input type="submit" name="ApplyButton" value="Save" class="button ui-corner-all ui-state-default " />
                    <input type="submit" name="SaveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default " />
                    <%= Html.ActionButton("Cancel", "Index", "Home", new { area = "Agency" }, new { @class = "button ui-corner-all ui-state-default " })%>
                </div>
           </div>
    <% } %>
    <script type="text/javascript">
        $().ready(function() {
            initAddressAutoComplete('<%= Url.Action("GetSuburbs", "Suburb", new { area = "Admin" }) %>', '#Agency_PostalState_Id', '#Agency_PostalSuburb', '#Agency_PostalPostCode');
            initAddressAutoComplete('<%= Url.Action("GetSuburbs", "Suburb", new { area = "Admin" }) %>', '#Agency_StreetState_Id', '#Agency_StreetSuburb', '#Agency_StreetPostCode');
        });

        function checkForFile()
        {
            if ($("#EntryNotificationLetter").val() == "")
            {
                alert("Please select a file to import.");
                return false;
            }
            return true;
       }

    </script>
</asp:Content>


