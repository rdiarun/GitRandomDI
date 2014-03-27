<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="DetectorInspector.Views.ViewPage" %>

<asp:Content ContentPlaceHolderID="InitContent" runat="server">
<%
    Page.Title = ViewData["EntityTypeDisplayName"] + " Management";
%> 
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<h2><%= Page.Title %></h2>

<table id="list"></table>
<div id="pager"></div>

<div class="buttons">
	<%= Html.ActionButton("Add", "Edit", "ReferenceData", new { id = 0 }, new { @class = "button ui-corner-all ui-state-default" })%>		
</div>

<% using (Html.BeginForm("Delete", "ReferenceData", FormMethod.Post, new { id = "delete-form" })) {%>
    <%= Html.AntiForgeryToken()%>
    <%= Html.Hidden("RowVersion")%>
<% } %>

<script type="text/javascript">
    var grid = $('#list');

    $().ready(function() {
        grid.jqGrid({
        url: '<%= Url.Action("GetItems") %>',
                 
            colNames: ['Id', 'RowVersion', 'Name','', ''],
            colModel: [
                { name: 'id', index: 'Id', key: true, hidden: true, width: 0 },
                { name: 'rowVersion', index: 'RowVersion', hidden: true, width: 0 },
                { name: 'name', index: 'Name', hidden: false, align: 'left', sortable: true, sorttype: 'text' },
                { name: 'editLink', width: '40px', fixed: true, resizable: false, align: 'center', sortable: false },
                { name: 'deleteLink', width: '55px', fixed: true, resizable: false, align: 'center', sortable: false }
            ],
            pager: '#pager',
            sortname: 'Name',
            sortorder: 'asc',
            loadComplete: function() {
                var dataIds = grid.getDataIDs();

                for (var i = 0; i < dataIds.length; i++) {
                    var rowData = grid.getRowData(dataIds[i]);

                    grid.setRowData(rowData.id, {
                        editLink: '<a href="<%= Url.Action("Edit") %>/' + rowData.id + '" class="button-edit">Edit</a>',
                        deleteLink: '<a href="#" onclick="confirmDelete(\'' + rowData.id + '\', \'' + escape(rowData.name) + '\', \'' + rowData.rowVersion + '\'); return false;" class="button-delete">Delete</a>'
                    });
                }
            },
            ondblClickRow: function(id) {
                goToReferenceData(id);
            }
        })

        grid.jqGrid('navGrid', '#pager', { search: false, edit: false, add: false, del: false });

        $('#delete-dialog').dialog({
            height: 200,
            autoOpen: false
        });
    });

    function confirmDelete(id, name, rowVersion) {       
        $('#deleteTitle').text(unescape(name));

        var deleteDialog = $('#delete-dialog');

        deleteDialog.dialog('option', 'buttons',
        {
            'No': function() {
                $(this).dialog('close');
            },
            'Yes': function() {
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

    function goToReferenceData(id) {
        document.location.href = '<%= Url.Action("Edit") %>/' + id;
    }

</script>

<div id="delete-dialog" style="display:none;" title="Delete Item">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to delete the <%= Html.Encode(ViewData["EntityTypeDisplayName"]) %> &quot;<span id="deleteTitle"></span>&quot;?</p>
</div>

    <div class="trail">
        <% switch (ViewData["EntityTypeName"].ToString())
           { %>
           <% case "CommentCategory": %>
            <a href="#" onclick="showHelpDialog('6B7538DF-AD69-4236-BBDB-52BB66FAC813');return false;">Help</a>
           <% break; %>
           <% case "CommunicationMethod": %>
            <a href="#" onclick="showHelpDialog('CE5E5DF4-A772-4539-BED5-0225034DAF37');return false;">Help</a>
           <% break; %>
           <% case "ContactType": %>
            <a href="#" onclick="showHelpDialog('6C81EC2C-88D4-4ffd-8971-C24D3B5A3165');return false;">Help</a>
           <% break; %>
           <% case "PropertyDescriptor": %>
            <a href="#" onclick="showHelpDialog('5B653C2A-1700-4f31-AC09-A19A629FD486');return false;">Help</a>
           <% break; %>
           <% case "PropertyUse": %>
            <a href="#" onclick="showHelpDialog('E85D6A45-E519-4a05-8ECD-7A0E2662182A');return false;">Help</a>
           <% break; %>
           <% case "ServiceType": %>
            <a href="#" onclick="showHelpDialog('34744481-03A6-4483-8CB7-8C39963F8452');return false;">Help</a>
           <% break; %>
           <% case "TaskCategory": %>
            <a href="#" onclick="showHelpDialog('C13FABFF-9707-41d4-ABA1-C042F753B406');return false;">Help</a>
           <% break; %>
           <% case "TenureType": %>
            <a href="#" onclick="showHelpDialog('BFB78E87-1C31-4ed7-80B6-E6CA80B752E0');return false;">Help</a>
           <% break; %>
           <% case "ValuationPurpose": %>
            <a href="#" onclick="showHelpDialog('6741DA4A-F3E4-467d-9053-33E13145D755');return false;">Help</a>
           <% break; %>
        <%} %>
    </div>
</asp:Content>
