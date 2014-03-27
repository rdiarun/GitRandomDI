<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Dialog.Master" Inherits="DetectorInspector.Views.ViewPage<DetectorInspector.Areas.Files.ViewModels.UploadContainerViewModel>" %>

<asp:Content runat="server" ContentPlaceHolderID="MainContent">
<% Html.EnableClientValidation(); %> 

<% using (var form = Html.BeginForm("Edit", "Home", FormMethod.Post, new { id = "create-form", enctype = "multipart/form-data", target = "fileFrame" }))
   { %>
    <%= Html.AntiForgeryToken() %>
    <%= Html.HiddenFor(o => ViewData.ModelState.IsValid) %>

	<%= Html.JQueryUIValidationSummary("Please correct the following errors before continuing: ", "create-form") %>

	<div class="row">
		<%= Html.LabelFor(model => Model.UploadContainer.Name) %>
		<%= Html.TextBoxFor(model => Model.UploadContainer.Name, new { maxlength = 150, @class = "textbox" })%>
		<%= Html.ValidationMessageFor(model => Model.UploadContainer.Name) %>
		<%= Html.RequiredFieldIndicator() %>
	</div>            

	<div class="row">
        <label>File</label>
        <input type="file" name="UploadContainer.UploadedFile" />
        <%= Html.RequiredFieldIndicator() %>                                      
    </div>
    
    	
		<div class="row">
            <label>File</label>
            <span class="read-only"><a href="<%= Url.Action("Download", new { id = Model.UploadContainer.Id }) %>"><%= Model.UploadContainer.UploadedFile.OriginalFileName%></a></span>
        </div>
		
	
<% } // end form %>

<iframe name="fileFrame" id="fileFrame" frameborder="0" style="display:none;"></iframe> 

<script type="text/javascript">


   
    
</script>
 
<% if (Request.Form.Count > 0) { %>
    <% if (ViewData.ModelState.IsValid) { %>
     
    <script type="text/javascript">
         parent.closeFileDialog();  
    </script>
    <%} else {%>
    
        
    <%= Html.IncludeScript("~/Content/Scripts/jquery.min.js") %>
    <script type="text/javascript">

       

        alert(parent.document.getElementById('dialog-container').innerHTML);
        
    </script>
    
    <%} %>
<%} %>

</asp:Content>
