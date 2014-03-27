<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.ServiceSheet.ViewModels.ElectricalJobViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.Booking.Id) + " Electrical Job";
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
                    <% using (var form = Html.BeginForm("ElectricalJob", "Home", new { id = Model.Booking.Id, propertyInfoId = Model.Booking.PropertyInfo.Id }, FormMethod.Post, new { id = "edit-service-sheet-form" }))
                    { %>           
                        <%= Html.AntiForgeryToken() %>
                        <%= Html.HiddenFor(model => model.ServiceSheet.RowVersion)%>
                        <%= Html.Hidden("ServiceSheet.Technician.Id", Model.Booking.Technician!=null?Model.Booking.Technician.Id.ToString():string.Empty)%>
                        <%= Html.Hidden("Booking.Zone.Id", Model.Booking.Zone.Id.ToString("D"))%>
                        <%= Html.Hidden("ServiceSheet.Date", StringFormatter.LocalDate(Model.Booking.Date))%>
                    <% Html.RenderAction("Details", "Contact", new { area = "PropertyInfo", id= Model.Booking.PropertyInfo.Id }); %>
                    <div class="left">
                        <div class="row">
                            <%= Html.LabelFor(model => model.Booking.Technician)%>
                            <span class="read-only"><%=Model.Booking.Technician!=null?Model.Booking.Technician.Name:"Not Required" %></span>
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
                            <%= Html.LabelFor(model => model.Booking.KeyNumber)%>
                            <%= Html.TextBoxFor(model => model.Booking.KeyNumber)%>
                        </div>    
                        <div class="row">
                            <%= Html.LabelFor(model => Model.Booking.Notes)%>
                            <%= Html.TextAreaFor(model => Model.Booking.Notes)%>
                        </div>
                    </div>
                    <div class="clear spacer"></div>   
                    <fieldset style="width: 847px;">
                        <div class="widget service-sheet-item" id="service-sheet-item">                               
                            <% Html.RenderPartial("EditElectricalJobItem"); %>
                        </div>	                    
                    </fieldset>                 
                    <div class="clear"></div>
                    <div class="left">
                        <%=Html.Image("sticker", "~/Content/Images/signature.png", "Signature", "Signature", new { style = "padding: 0px 2px 0px 2px" })%>
                        <%=Html.Image("sticker", "~/Content/Images/card.png", "Card Left", "Card Left", new { style = "padding: 0px 2px 0px 2px" })%>
                        <%=Html.Image("sticker", "~/Content/Images/tick.png", "Completed", "Completed", new { style = "padding: 0px 2px 0px 2px" })%>
                        <div class="clear"></div>
                        <%= Html.CheckBoxFor(model=> model.ServiceSheet.HasSignature)%>
                        <%= Html.CheckBoxFor(model=> model.ServiceSheet.IsCardLeft)%>
                        <%= Html.CheckBoxFor(model=> model.ServiceSheet.IsCompleted)%>
                    </div>
                    <div class="right">
                        <div class="buttons">
                            <input type="button" name="CloneButton" value="Clone"   class="button ui-corner-all ui-state-default " onclick="javascript:saveServiceSheetItems(<%=Model.ServiceSheet.Id %>);editServiceSheetItem(true);return false;" />
                            <input type="button" name="AddButton" value="Add"   class="button ui-corner-all ui-state-default " onclick="javascript:saveServiceSheetItems(<%=Model.ServiceSheet.Id %>);editServiceSheetItem(false);return false;" />
                            <input type="submit" name="SaveButton" id="saveButton" value="Save &amp; Close" class="button ui-corner-all ui-state-default "/>
                            <input type="button" onclick="javascript:window.close()" value="Cancel"  class="button ui-corner-all ui-state-default " />
                        </div>
                    </div>
                    <div class="clear"></div>
                    <div class="left">
                        <fieldset class="narrow">
                            <legend>Problems</legend>
                            <div class="row">
                                <%= Html.LabelFor(model => model.ServiceSheet.HasProblem)%>
                                <%= Html.DropDownListFor(model => model.ServiceSheet.HasProblem, Html.GetYesNoSelectListItems(), new { @class = "narrow" })%>
                            </div>    
                            <div class="row">
                                <%= Html.LabelFor(model => model.ServiceSheet.Notes)%>
                                <%= Html.TextAreaFor(model => model.ServiceSheet.Notes, new { @class="narrow" })%>
                            </div>
                        </fieldset>
                    </div>
                    <div class="right">     
                        <fieldset class="narrow">  
                            <legend>Electrical</legend>
                            <div class="row">
	                            <%=Html.LabelFor(model=>Model.ServiceSheet.IsElectricianRequired) %>
	                            <%= Html.DropDownListFor(model => Model.ServiceSheet.IsElectricianRequired, Html.GetYesNoSelectListItems(), new { @class = "narrow" })%>
                            </div>   
                            <div class="row">
                                <%= Html.LabelFor(model => model.ServiceSheet.ElectricalNotes)%>
                                <%= Html.TextAreaFor(model => model.ServiceSheet.ElectricalNotes, new { @class="narrow" })%>
                            </div>    
                        </fieldset>
                    </div>
                    <div class="clear"></div>
                    <% } %>                   
                </div>
           </div>
           
           <div id="confirmDialog" style="display:none">Please confirm that you would like to proceed without marking this job as <b>"Completed"</b>.</div>

           <script type="text/javascript">

                $.validator.addMethod("detectorVal", function(value, element) {
                    if (value == 1) {
                        var expiryYear = parseInt($(element).parent().parent().find("input[id*=ServiceSheetItem_ExpiryYear]").val());
                        // effectively checks if the detector expires in a future year. If so, validation error doesn't show.
                        // Otherwise, if no year is entered, or it expired this year or previously, the 'is replaced' flag must be set
                        // the one exception to this rule, is if the user has indicated that the detector is 'not required'.
                        if ($(element).parent().parent().find("input[id*=ServiceSheetItem_IsOptional]").is(':checked')) {
                            return true;
                        }
                        
                        if (!isNaN(expiryYear)) {
                            if (expiryYear <= (new Date).getFullYear()) {
                                return $(element).parent().parent().find("input[id*=ServiceSheetItem_IsReplacedByElectrician]").is(':checked');        
                            }
                        }
                        else {
                            return $(element).parent().parent().find("input[id*=ServiceSheetItem_IsReplacedByElectrician]").is(':checked');        
                        }
                    }

                    return true;}
                    , "Mains detector type is missing the Electrician Replaced flag.");
                
                $().ready(function() {
                    
                    var dialog = $('#confirmDialog');

                    dialog.dialog({
                        width: 300,
                        height: 100,
                        title: 'Confirm service sheet is not completed',
                        autoOpen: false,
                        buttons: {
                            "Confirm": function() {
                                $(this).dialog('close');
                                saveServiceSheetItems(<%=Model.ServiceSheet.Id %>);
                                $('#edit-service-sheet-form').submit();
                            },
                            "Cancel": function() {
                                $(this).dialog('close');
                            }
                        }
                    });

                    $('#saveButton').click(function(e) {
                        e.preventDefault();
                        var completedInput = $('#ServiceSheet_IsCompleted');
                        
                        if (completedInput.length) {
                            if (completedInput.is(':checked')) {
                                //save items
                                saveServiceSheetItems(<%=Model.ServiceSheet.Id %>);
                                $('#edit-service-sheet-form').submit();
                            } 
                            else {
                                dialog.dialog('open');
                            }    
                        }
                        
                        //
                        
                        
                    });

                    //init('#booking');
                    var container = $('div#validation-summary-edit-booking-form');


                    $("#edit-service-sheet-form").validate({
                        errorContainer: container,
                        errorLabelContainer: $("ul", container),
                        wrapper: 'li',
                        invalidHandler: function(form, validator) {
                            var errors = validator.numberOfInvalids();
                            if (errors) {
                                $(container).show();
                            } else {
                                $(container).hide();
                            }
                        }
                    });
                });
                  
              
               function toggleDetectorTypeValidation(showMessage) {
                   var mainsError = $('.validation-summary #validation-message ul li#mainsError');
                   
                   if (mainsError.length > 0) {
                       $('.validation-summary #validation-message ul').remove(mainsError);
                   }

                    if (showMessage) {
                        $('.validation-summary #validation-message ul').append('<li id="mainsError">One or more mains detectors are missing the Electrician Replaced flag.</li>');
                    }

                    if ($('.validation-summary #validation-message ul li').length > 0) {
                        $('#validation-summary-edit-booking-form').show();
                    }
                   else {
                        $('#validation-summary-edit-booking-form').hide();
                    }
                   
                   
               }


                function editServiceSheetItem(isClone) {
                    debugger;
                    $.ajax({
                        type: 'GET',
                        url: '<%= Url.Action("EditServiceSheetItem", "Home", new { bookingId = Model.Booking.Id, isClone="_CLONE_"  }) %>'.replace(/_CLONE_/g, isClone),
                        success: function (result) {
                            loadServiceSheet(result);
                        }
                    });
                }

                function loadServiceSheet(result) {
                    debugger;
                    var editDialog = $('#service-sheet-item');
                    editDialog.html(result);

                    editDialog.dialog('option', 'buttons',
		            {
			            'Cancel': function () {
			                $(this).dialog('close');
			            }
		            });

		            init('#service-sheet-item');
                }

                function saveServiceSheetItems() {
                    


                    var itemCount = $('#ServiceSheetItem_Count').val();

                    for (var i = 0; i < itemCount; i++) {
                        var itemId = $('#ServiceSheetItem_Id_' + i).val();
                        var itemLocation = $('#ServiceSheetItem_Location_' + i).val();
                        var itemDetectorTypeId = $('#ServiceSheetItem_DetectorType_Id_' + i).val();
                        var itemManufacturer = $('#ServiceSheetItem_Manufacturer_' + i).val();
                        var itemExpiryYear = $('#ServiceSheetItem_ExpiryYear_' + i).val();
                        var itemNewExpiryYear = $('#ServiceSheetItem_NewExpiryYear_' + i).val();
                        var itemIsBatteryReplaced = $('#ServiceSheetItem_IsBatteryReplaced_' + i).is(':checked');
                        var itemIsReplacedByElectrician = $('#ServiceSheetItem_IsReplacedByElectrician_' + i).is(':checked');        
                        var itemIsRepositioned = $('#ServiceSheetItem_IsRepositioned_' + i).is(':checked');
                        var itemIsCleaned = $('#ServiceSheetItem_IsCleaned_' + i).is(':checked');
                        var itemHasSticker = $('#ServiceSheetItem_HasSticker_' + i).is(':checked');
                        var itemIsRequiredForCompliance = $('#ServiceSheetItem_IsRequiredForCompliance_' + i).is(':checked');
                        var itemIsDecibelTested = $('#ServiceSheetItem_IsDecibelTested_' + i).is(':checked');
                        var itemIsOptional = $('#ServiceSheetItem_IsOptional_' + i).is(':checked');
                        var itemHasProblem = $('#ServiceSheetItem_HasProblem_' + i).is(':checked');

                        $.ajax({
                            url: '<%= Url.Action("EditServiceSheetItem", "Home") %>',
                            dataType: 'json',
                            data: {
                                serviceSheetId: <%=Model.ServiceSheet.Id %>,
                                id: itemId,
                                location: itemLocation,
                                detectorTypeId: itemDetectorTypeId,
                                manufacturer: itemManufacturer,
                                expiryYear: itemExpiryYear,
                                newExpiryYear: itemNewExpiryYear,
                                isBatteryReplaced: itemIsBatteryReplaced,
                                isReplacedByElectrician: itemIsReplacedByElectrician,
                                isRepositioned: itemIsRepositioned,
                                isCleaned: itemIsCleaned,
                                hasSticker: itemHasSticker,
                                isRequiredForCompliance: itemIsRequiredForCompliance,
                                isDecibelTested: itemIsDecibelTested,
                                isOptional: itemIsOptional,
                                hasProblem: itemHasProblem
                            },
                            success: function (result) {
                                
                            }
                        });

                        
                    }

                };



                function deleteServiceSheetItem(id, name, rowVersion) {

                    var deleteDialog = $('<div id="delete-service-sheet-item-dialog" style="display:none;" title="Delete Item"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you wish to delete &quot;' + unescape(name) + '&quot;. Continue?</p></div>');
                    deleteDialog.dialog({
                        height: 230
                    });
                    deleteDialog.dialog('option', 'buttons',
		            {
			            'No': function () {
			                $(this).dialog('close');
			            },
			            'Yes': function () {
			                $(this).dialog('close');

			                var rowVersionHidden = $('#ServiceSheetItem_RowVersion')[0];

			                rowVersionHidden.value = rowVersion;

			                var form = $('#delete-service-sheet-item-form')[0];

			                form.action = '<%= Url.Action("DeleteServiceSheetItem", "Home", new { id="_ID_", bookingId = Model.Booking.Id }) %>'.replace(/_ID_/g, id);
			                form.submit();
			            }
		            });

                    deleteDialog.dialog('open');
                };
    
        </script>
</asp:Content>


