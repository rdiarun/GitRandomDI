<%@ Page Language="C#" MasterPageFile="~/Views/Shared/NewWindow.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<% 
    Page.Title = Html.GetCreateEditText(Model.PropertyInfo.Id) + " Property";
%>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
	
    <h2><%=Page.Title %></h2>
  	
    <div class="ui-tabs ui-widget ui-widget-content ui-corner-all" id="tabs">
        <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Details", "Edit", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <% if (!Model.IsCreate())
                { %>          
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Contact Details", "Index", "Contact", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <li class="ui-state-default ui-corner-top ui-tabs-selected ui-state-active"><a href="#details-tab">Bookings</a></li>
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Service History", "ServiceSheet", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <li class="ui-state-default ui-corner-top"><%= Html.ActionLink("Landlord Details", "Landlord", "Home", new { area = "PropertyInfo", id = Model.PropertyInfo.Id }, null)%></li>
            <%} %>
        </ul>
            
        <div class="ui-tabs-panel ui-widget-content ui-corner-bottom" id="details-tab">
            <table id="list"></table>
            <div id="pager"></div>

            <div class="buttons">
	                <input type="button" class="button ui-corner-all ui-state-default" value="Add" onclick="javascript: newBooking('<%=Model.PropertyInfo.Id %>');" />
            </div>

            <% using (Html.BeginForm("Delete", "Home", FormMethod.Post, new { id = "delete-form" }))
                {%>
                <%= Html.AntiForgeryToken()%>
                <%= Html.Hidden("RowVersion")%>
            <% } %>

            <script type="text/javascript">
                var grid = $('#list');

                $().ready(function () {
                    grid.jqGrid({
                        width: 871,
                        url: '<%= Url.Action("GetItems", "Home", new { area = "Booking" }) %>',
                        postData: { propertyInfoId: '<%=Model.PropertyInfo.Id %>' },
                        colNames: ['', 'Id', 'RowVersion', 'Unit', 'House', 'Street', 'Suburb', 'State', 'PCode', 'Agency', 'Key Number',  'Time',  'Key/Time', 'Notes', '', ''],
                        colModel: [
                            { name: 'id', index: 'Id', key: true, hidden: true, width: 100 },
                            { name: 'propertyInfoId', index: 'PropertyInfoId', hidden: false, width: '60px', align: 'left', sortable: true, sorttype: 'int' },
                            { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 40 },
                            { name: 'unitShopNumber', index: 'UnitShopNumber', hidden: false, width: '60px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'streetNumber', index: 'StreetNumber', hidden: false, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'streetName', index: 'StreetName', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'suburb', index: 'Suburb', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'state', index: 'State.Name', hidden: false, width: '70px', align: 'center', sortable: true, sorttype: 'text' },
                            { name: 'postCode', index: 'PostCode', hidden: false, width: '75px', align: 'center', sortable: true, sorttype: 'text' },
                            { name: 'agencyName', index: 'Agency.Name', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'keyNumber', index: 'KeyNumber', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'time', index: 'Time', hidden: true, width: '70px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'keyTime', index: 'Time', hidden: false, width: '160px', align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'notes', index: 'Notes', hidden: false, width: 200, align: 'left', sortable: true, sorttype: 'text' },
                            { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                            { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
                        ],
                        pager: '#pager',
                        sortname: 'Date',
                        sortorder: 'asc',
                        loadComplete: function () {
                            var dataIds = grid.getDataIDs();

                            for (var i = 0; i < dataIds.length; i++) {

                                var rowData = grid.getRowData(dataIds[i]);

                                grid.setRowData(rowData.id, {
                                    editLink: '<a href="#" onclick="openBooking(' + rowData.id + ' , \'<%=Model.PropertyInfo.Id %>\', false);return false;" class="button-edit">Edit</a>',
                                    deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                                });
                            }
                        },
                        ondblClickRow: function (id) {
                            openBooking(id , '<%=Model.PropertyInfo.Id %>', false);
                        }
                    })

                    grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

                    $('#dialog').dialog({
                        modal: true,
                        autoOpen: false
                    });
                });

                function confirmDelete(id, name, rowVersion) {
                    $('#deleteTitle').text(unescape(name));

                    var deleteDialog = $('#dialog');

                    deleteDialog.dialog('option', 'buttons',
                    {
                        'No': function () {
                            $(this).dialog('close');
                        },
                        'Yes': function () {
                            $(this).dialog('close');

                            var rowVersionHidden = $('#RowVersion')[0];

                            rowVersionHidden.value = rowVersion;

                            var form = $('#delete-form')[0];

                            form.action = '<%= Url.Action("Delete") %>/' + id;
                            form.submit();
                        }
                    });

                    deleteDialog.dialog('open');
                }

                function refreshGrid()
                {
                    var grid = $('#list');
                    reloadGrid(grid);   
                }


            </script>

            <div id="dialog" style="display:none;" title="Delete Item">
	            <p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to delete the item &quot;<span id="deleteTitle"></span>&quot;?</p>
            </div>

        </div>
    </div>

</asp:Content>


