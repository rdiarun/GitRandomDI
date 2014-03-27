<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl<DetectorInspector.ViewModels.PageHelpViewModel>" %>
 
<div class="trail">
    <% if (Html.IsEdit(Model.Help.Id)) { %>
        <a href="#" onclick="showHelpDialog(<%=Model.Help.Id %>);return false;" title="Last Modified <%=Html.UtcToLocalDateTime(Model.Help.ModifiedUtcDate) %>">Help</a>
        
        <% //If blink is too awesome for your project, replace with styles %>
        <% if (Model.Help.ModifiedUtcDate >= DateTime.Now.AddMonths(-1)) { %>
            <blink>
            <% if (Model.Help.ModifiedUtcDate >= Model.Help.CreatedUtcDate) { %>
                updated!
            <%} else { %>
                new!
            <%}%>
            </blink>
        <%}%>
    <%} %>
    
    <% if (HttpContext.Current.User.HasPermission(Permission.AdministerSystem)) { %>

    | <a href="#" onclick="editHelpDialog('<%=Model.Help.Code %>');return false;"><%=Html.GetCreateEditText(Model.Help.Id) + " Help" %></a>
    
    <%} %>
    
</div>

<script type="text/javascript">

    function showHelpDialog(id) {

        loadDialog({ url: '<%= Url.Action("ShowHelp", "Help",  new { area="Admin", id="_ID_"}) %>'.replace(/_ID_/g, id),
        buttonType: 'read'

        });
    }

    function editHelpDialog(code) {
      
        loadDialog({ url: '<%= Url.Action("EditPage", "Help",  new { area="Admin", code="_CODE_"}) %>'.replace(/_CODE_/g, code),
        buttonType: 'edit'

                },
                {
                    width: 1000
                });      
    }
    
</script>