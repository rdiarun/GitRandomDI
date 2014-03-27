<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel>" %>
	<% using (Html.BeginForm("Noaction", "ChangeLog", FormMethod.Post, new { id = "log-form" }))
   {%>
	<%= Html.AntiForgeryToken()%>
	<% } %>
    <div style="">
	    <table id="log-list"></table>
	    <div id="log-pager"></div>
    </div>

    <div style="">
	    <fieldset style="width: 377px;height:300px;">
            <div></div>
		    <div  id="item-details">
		    </div>	                    
	    </fieldset>   
    </div>            	
	<script type="text/javascript">

		var sGrid = $('#log-list');


		$().ready(function () {

			sGrid.jqGrid({
				url: '<%= Url.Action("GetItems", "ChangeLog") %>',
				width: 700,
				height: 200,
				postData: { propertyInfoId: '<%=Model.PropertyInfo.Id %>' },
				gridview: true,
				colNames: ['Id', 'Date/Time', 'Type','User'],
				colModel: [
					{ name: 'id', index: 'Id', key: true, hidden: true, width: 10 },
					{ name: 'dateTime', index: 'DateTime', hidden: false, width: 50, align: 'left', sortable: false, sorttype: 'text' },
					{ name: 'itemType', index: 'ItemType', hidden: false, width: 150, align: 'left', sortable: false, sorttype: 'text' },
                    { name: 'userName', index: 'UserName', hidden: false, width: 100, align: 'left', sortable: false, sorttype: 'text' },
				],
				pager: '#log-pager',
				sortname: 'CreatedUtcDate',
				sortorder: 'desc',
				onSelectRow: function (rowId) {
				    displaySelectedRow(rowId);
				    },
				loadComplete: function () {
				  //  displaySelectedRow(1);
				}

			});

			sGrid.jqGrid('navGrid', '#log-pager', { search: false, edit: false, add: false, del: false });

		});



	    function displaySelectedRow(id)
	    {


			$.ajax({
				type: 'POST',
				url: '<%= Url.Action("GetDetails", "ChangeLog", new { id="_ID_" }) %>'.replace(/_ID_/g, id),
			    success: function (result) {
                    displayDetails(result, id);
				}
			});
		}

	    function displayDetails(r, i)
	    {
	        $('#item-details').html(r.itemData);
	    }


	</script>


