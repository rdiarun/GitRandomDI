<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl<Kiandra.Entities.IEntity>"  %>

<% if (HttpContext.Current.User.HasPermission(Permission.AdministerSystem))
   { %>

<div id="audit-dialog" style="display: none" title="Audit Trail">
    <table id="audit-trail-table"></table>
    <div id="audit-trail-pager"></div>
</div>

<script type="text/javascript">
    var auditIntialized = false;
    
    function showAuditDialog() {
        if (!auditIntialized) {
            var grid = $('#audit-trail-table');

            grid.jqGrid("setGridParam", { postData: null });
            grid.jqGrid({
                url: '<%= Url.Action("GetAuditEntries", "Audit", new { area = "" }) %>',
                postData: { entityType: '<%= Model.GetType().Name %>', entityKey: '<%= Model.Id %>' },
                gridview: true,
                colNames: ['Id', 'Action', 'User', 'Date Created'],
                colModel: [
                    { name: 'id', index: 'Id', hidden: true, width: 40, align: 'right', sortable: true, sorttype: 'int' },
                    { name: 'action', index: 'Description', width: 500, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'user', index: 'User', width: 150, align: 'left', sortable: true, sorttype: 'text' },
                    { name: 'createdUtcDate', index: 'CreatedUtcDate', width: 140, align: 'left', sortable: true, sorttype: 'text' }
                ],
                pager: '#audit-trail-pager',
                sortname: 'CreatedUtcDate',
                sortorder: 'desc',
                height: 340,
                width: 860,
                subGrid: true,
                gridview: false,
                subGridUrl: '<%= Url.Action("GetAuditEntryActions", "Audit", new { area = "" }) %>',
                subGridModel: [{
                    name: ['Action', 'Item', 'Item ID', 'Property', 'Value'],
                    width: [80, 100, 50, 90, 500],
                    align: ['left', 'left', 'right', 'left', 'left'],
                    params: ['id']
                }],
                onSelectRow: function(id) {
				    $(this).toggleSubGridRow(id);
			    }
            });

            grid.jqGrid('navGrid', '#audit-trail-pager', { search: false, edit: false, add: false, del: false });

            auditIntialized = true;
        }
        
        var auditDialog = $('#audit-dialog');

        auditDialog.dialog({
            height: 450,
            width: 900,
            modal: false            
        }).dialog('open');

        return false;       
    };
    
    </script>

    <a href="#" onclick="return showAuditDialog();">View Audit Trail</a>
<% } %>
