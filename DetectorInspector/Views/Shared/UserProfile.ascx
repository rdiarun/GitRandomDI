<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl<DetectorInspector.ViewModels.RegisterViewModel>" %>

<div class="row">    
    <%= Html.LabelForKiandra(model => model.Profile.EmailAddress)%>
    <%= Html.TextBoxFor(model => model.Profile.EmailAddress, new { maxlength = 150, @class = "textbox" })%>
    <%= Html.RequiredFieldIndicator() %>
</div>
 		
<div class="row">
    <%= Html.LabelForKiandra(model => model.Profile.FirstName)%>
    <%= Html.TextBoxFor(model => model.Profile.FirstName, new { maxlength = 150, @class = "textbox" })%>
    <%= Html.RequiredFieldIndicator() %>
</div>

<div class="row">
    <%= Html.LabelForKiandra(model => model.Profile.LastName)%>
    <%= Html.TextBoxFor(model => model.Profile.LastName, new { maxlength = 150, @class = "textbox" })%>
    <%= Html.RequiredFieldIndicator() %>
</div>