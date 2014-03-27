<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl" %>

<%
var message = TempData["NotificationMessage"] as DetectorInspector.ViewModels.NotificationMessage;

if (message != null) {
    var jsMessageType = message.MessageType == NotificationMessageType.Information ? "notificationMessageType.info" : "notificationMessageType.error";      
%>
    <script type="text/javascript">
        $(document).ready(function() {
            showNotificationMessage(<%= jsMessageType %>, '<%= message.Title.Replace("'", "\\'")%>' , '<%= message.Body.Replace("'", @"\\'") %>');
        });
    </script>   
<% } %>

<div id="notification-message-wrapper" style="display: none;">
    <div id="notification-message" class="ui-widget ui-corner-all">
      
        <span id="notification-message-icon" class="ui-icon"></span>
        <span id="notification-message-title"></span>
        <span id="notification-message-body"></span>    
       
    </div>
</div> 
        
<script type="text/javascript">
    var notificationMessageType = new Object();

    notificationMessageType.info = 1;
    notificationMessageType.error = 2;

    function showInfoMessage(title, body) {
        showNotificationMessage(notificationMessageType.info, title, body);
    }

    function showErrorMessage(title, body) {
        showNotificationMessage(notificationMessageType.error, title, body);
    }

    function showNotificationMessage(messageType, title, body) {

        var wrapper = $('#notification-message-wrapper');
        var container = $('#notification-message');
        var icon = $('#notification-message-icon');
        var titleEl = $('#notification-message-title');
        var bodyEl = $('#notification-message-body');

        titleEl.text(title);
        bodyEl.text(' - ' + body);

        container.removeClass('ui-state-default ui-state-error');
        icon.removeClass('ui-icon-info ui-icon-error');
        
        switch (messageType) {
            case notificationMessageType.info:
                container.addClass('ui-state-default');
                icon.addClass('ui-icon-info');
                break;

            case notificationMessageType.error:
                container.addClass('ui-state-error');
                icon.addClass('ui-icon-alert');
                break;
        }

        setTimeout(function() {
        wrapper.slideDown('slow');
        }, 1000);

        setTimeout(function() {
        wrapper.slideUp('slow');
        }, 10000);	
    }
</script>