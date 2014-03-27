<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl"  %>
<% using (Html.BeginForm("PropertyFind", "Home", new { area = "" }, FormMethod.Post, new { id = "property-find-form", @class="ignore-dirty", onsubmit = "javascript: return false;" }))
   { %>
        <div id="property-find" class="row">
            <%= Html.TextBox("FindProperty.Keywords", string.Empty, new { @class = "ignore-dirty textbox small", onkeypress = "javascript: if(checkEnterKey(event)){findProperty();};" })%>
            <input type="button" class="ignore-dirty button ui-corner-all ui-state-default" value="Find" onclick="javascript:findProperty();return false;" />
        </div>
<%
    }
 %>
 
<div id="result-dialog" style="display:none;" title="Properties Found">
    <table id="result-list"></table>
    <div id="result-pager"></div>
</div>

 <script type="text/javascript">
     function findProperty() {
         var keywords = $('#FindProperty_Keywords')[0].value.trim();

         $.ajax({
             url: '<%= Url.Action("FindProperty", "Home", new { area = "", keywords="_KEYWORDS_", quickSearch=true }) %>'.replace(/_KEYWORDS_/g, escape(keywords)),
             dataType: 'json',
             success: function (result) {
                 if (result.itemCount > 0) {
                     if (result.itemCount == 1) {
                         openPropertyInfo(result.id);
                     } else {
                         var dataIds = resultGrid.getDataIDs();
                         for (var i = 0; i < dataIds.length; i++) {
                             resultGrid.delRowData(dataIds[i]);
                         }

                         $.each(result.items, function (i, item) {
                             resultGrid.addRowData(item.id, { id: item.id,
                                 propertyNumber: item.propertyNumber,
                                 unitShopNumber: item.unitShopNumber,
                                 streetNumber: item.streetNumber,
                                 streetName: item.streetName,
                                 suburb: item.suburb,
                                 state: item.state,
                                 lastServicedDate: item.lastServicedDate,
                                 nextServiceDate: item.nextServiceDate,
                                 keyNumber: item.keyNumber,
                                 tenantName: item.tenantName,
                                 tenantContactNumber: item.tenantContactNumber,
                                 hasProblem: item.HasProblem,
                                 hasLargeLadder: item.HasLargeLadder,
                                 inspectionStatus: item.inspectionStatus,
                                 inspectionStatusEnum: item.inspectionStatusEnum,
                                 electricalWorkStatus: item.electricalWorkStatus,
                                 electricalWorkStatusEnum: item.electricalWorkStatusEnum,
                                 agencyName: item.agencyName,
                                 propertyManager: item.propertyManager,
                                 postCode: item.postCode  });
                         });
                         reloadGrid(resultGrid);

                         var resultDialog = $('#result-dialog');
                         resultDialog.dialog('option', 'buttons',
                            {
                                'Close': function () {
                                    $(this).dialog('close');
                                }
                            });

                         resultDialog.dialog('open');
                     }
                 } else {
                     showInfoMessage('Failed', 'Could not locate property');
                 }
             },
             error: function (result) {
                 showInfoMessage('Failed', 'Could not locate property');
             }
         });

     }

    var resultGrid = $('#result-list');

    $().ready(function() {
        resultGrid.jqGrid({
            datatype: 'clientSide',
            width: '1147',
            colNames: ['', 'RowVersion', 'Id', 'Unit/Shop', 'House', 'Street', 'Suburb', 'State', 'PCode', 'Due', 'Agency', 'Property Manager', 'Tenant', 'Contact Number', 'Problem', 'Large Ladder', 'Key Number', 'Inspection', 'Electrical Work', ''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: 100 },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                { name: 'propertyNumber', index: 'PropertyNumber', hidden: false, width: '50px', align: 'right', sortable: true, sorttype: 'integer' },
                { name: 'unitShopNumber', index: 'UnitShopNumber', hidden: false, width: '110px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'streetNumber', index: 'StreetNumber', hidden: false, width: '80px', align: 'left', sortable: true, sorttype: 'text' },
                { name: 'streetName', index: 'StreetName', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'suburb', index: 'Suburb', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'state', index: 'State.Name', hidden: false, width: '70px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'postCode', index: 'PostCode', hidden: false, width: '75px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'nextServiceDate', index: 'NextServiceDate', hidden: false, width: '130px', align: 'center', sortable: true, sorttype: 'text' },
                { name: 'agencyName', index: 'Agency.Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'propertyManager', index: 'PropertyManager.Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'tenantName', index: 'TenantName', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'tenantContactNumber', index: 'TenantContactNumber', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'hasProblem', index: 'HasProblem', hidden: true },
                { name: 'hasLargeLadder', index: 'HasLargeLadder', hidden: true },
                { name: 'keyNumber', index: 'KeyNumber', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'inspectionStatus', index: 'InspectionStatus.Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'electricalWorkStatus', index: 'ElectricalWorkStatus.Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#result-pager',
            sortname: 'Id',
            sortorder: 'desc',
            loadComplete: function() {
                var dataIds = resultGrid.getDataIDs();

                for (var i = 0; i < dataIds.length; i++) {

                    var rowData = resultGrid.getRowData(dataIds[i]);

                    resultGrid.setRowData(rowData.id, {
                        editLink: '<a href="#" onclick="openPropertyInfo(' + rowData.id + ');return false;" class="button-edit">View</a>'
                    });
                }
            },
            ondblClickRow: function (id) {
                openPropertyInfo(id);
            }
        })

        resultGrid.jqGrid('navGrid', '#result-pager', { search: false, edit: false, add: false, del: false });

        $('#result-dialog').dialog({
            width: 1160,
            height: 500,
            modal: true,
            autoOpen: false
        });

    });


 </script>
