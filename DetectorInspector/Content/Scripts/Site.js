var __focusedElement = null;

function confirmSignOut(el) {
    var div = $("<div id='signout-dialog'>Are you sure you wish to exit DetectorInspector?</div>")
        .appendTo(document.body);

    div.dialog({
        buttons: {
            No: function() { $(this).dialog('destroy').remove(); return false; },
            Yes: function() { window.location = $(el).attr('href'); }
        },
        autoOpen: true,
        title: 'Exit DetectorInspector?',
        height: 150,
        width: 300,
        modal: true,
        bgiframe: true,
        resizable: false,
        autoResize: false,
        overlay: { backgroundColor: 'black', opacity: 0.5 }
    }).dialog('moveToTop');
};


$(document).ready(function () {

    $.extend({
      getUrlVars: function(url){
        var vars = [], hash;
        var hashes = url.split('&');
        for(var i = 0; i < hashes.length; i++)
        {
          hash = hashes[i].split('=');
          vars.push(hash[0]);
          vars[hash[0]] = hash[1];
        }
        return vars;
      },
      getUrlVar: function(url,name){
        return $.getUrlVars(url)[name];
      }
    });


    // Configure AJAX defaults
    $.ajaxSetup({
        type: "POST",
        async: false,
        cache: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert('An error occurred attempting to process your request. This error has been logged.');
        }
    });

    jQuery.ajaxSettings.traditional = true;

    // Configure jqGrid defaults
    if ($.jgrid != undefined) {
        $.extend($.jgrid.defaults, {
            prmNames: {
                page: 'pageNumber',
                rows: 'pageSize',
                sort: 'sortBy',
                order: 'sortDirection',
                search: 'search',
                nd: 'nd'
            },
            datatype: 'json',
            jsonReader: { root: 'items', cell: '', id: '0', repeatitems: false, page: 'pageNumber', total: 'pageCount', records: 'itemCount' },
            mtype: 'POST',
            rowNum: 100,
            rowList: [25, 50, 100, 250],
            viewrecords: true,
            gridview: true,
            scroll: 1,
            height: 350,
            width: 948,
            loadError: function (XMLHttpRequest, status, exception) {
                // 0x80004005 (NS ERROR FAILURE)
                // This occours when we rapidly send many ajax requests at the same time reolading or changing the page, resulting in an abandoned/stale response
                // e.g. hiting "Contacts" repeatedly.  This is allegedly a bug in FireFox, only occours in FireFox
                // see: http://helpful.knobs-dials.com/index.php/0x80004005_%28NS_ERROR_FAILURE%29_and_other_firefox_errors#0x80004005_.28NS_ERROR_FAILURE.29
                if (exception != undefined) {
                    if (exception.name != 'NS_ERROR_FAILURE') {
                        alert('Error retrieving data. Please try refreshing the page.');
                    }
                }
            }
        });
    }

    // Configure jQueryUI Dialog defaults
    $.extend($.ui.dialog.defaults, {
        overlay: { background: "#000", opacity: 0.8 },
        modal: true,
        bgiframe: true,
        autoOpen: false,
        resizable: false,
        height: 400,
        width: 500
    });


    $("#menu li").hover(
        function () {
            $(this).addClass("hover");
            $(this).find("iframe").show();
        },
        function () {
            $(this).removeClass("hover");
            $(this).find("iframe").hide();
        }
    );


    // Add iframes to drop downs for IE6 so that they appear over selects.
    $("#menu li ul").each(
        function () {
            $(this).width($(this).width());
            $(this).before('<iframe class="menuIframe" scrolling="no" frameborder="0" style="display:none;width: ' + $(this).width() + 'px; height: ' + $(this).height() + 'px;margin-left:' + $(this).css("margin-left") + ';margin-top:' + $(this).css("margin-top") + '"></iframe>');
        }
    );

    init('');


});

function init(root) {
	$(root + ' :input')
        .focus(function() {
        	__focusedElement = $(this);
        });

	// Focus the first input element on the page.
    $(root + ' :input:visible:enabled:first').focus();


	// Add hover feedback to all buttons
	$(root + ' button, input[type=button], input[type=submit]').hover(function() {
		$(this).addClass('ui-state-hover');
	}, function() {
		$(this).removeClass('ui-state-hover');
	});

	$(root + ' .datepicker').datepicker({
		dateFormat: 'dd/mm/yy',
		changeMonth: true,
		changeYear: true
});

    $(root + ' .money').autoNumeric();

    $(root + ' .clockpick').timemachine({
        format:'AMPM',
        showSecs: false
    });

	$(root + ' .postcode').setMask({ mask: '9', type: 'repeat', 'maxLength': 4 });


	if ($(root + ' .html-editor').tinymce != undefined) {
	    $(root + ' .html-editor').tinymce({
	    script_url: _applicationRoot + 'Content/Scripts/tiny_mce/tiny_mce.js',
	        theme: 'advanced',
	        plugins: 'paste,fullpage',
	        theme_advanced_buttons1: 'bold,italic,underline,|,bullist, numlist,|,outdent,indent,|,cut,copy,paste,pasteword,|,link,unlink, code',
	        theme_advanced_buttons2: '',
	        theme_advanced_toolbar_align: 'left',
	        theme_advanced_toolbar_location: 'top',
	        fullpage_default_font_family: 'Tahoma, Arial, Helvetica, sans-serif',
	        fullpage_default_font_size: '10pt',
	        fullpage_default_text_color: 'black',
	        fullpage_default_xml_pi: false,
	        height: '300px',
	        width: '700px'
	    });
	}
	
};


function getRadioButtonListValue(name) {
	// return the selected value from the named radio button list
	return $('input[name=' + name + ']:checked').val(); 
};

function getCheckBoxListValues(name) {
	// return an array of selected values from the named check box list
	var result = [];
	$('input[name=' + name + ']:checked').each(function() { result.push($(this).val()); });
	return result;
};

function checkAll(name, classes, flag) {
    if (name != null) {
        $("input[name=" + name + "][type='checkbox']").attr('checked', flag);
    }
    if (classes != null) {
        var arr = classes.split(',');
        for (var i = 0; i < arr.length; i++) {            
            $(" ." + arr[i] + " input[type='checkbox']").attr('checked', flag);
        }
    }
}



String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g, '');
};

String.prototype.ltrim = function() {
    return this.replace(/^\s+/, '');
};

String.prototype.rtrim = function() {
    return this.replace(/\s+$/, "");
};

function reloadGrid(grid) {
    var sortBy = grid.jqGrid("getGridParam","sortname");
    grid.jqGrid("setGridParam",{ sortname: sortBy }).trigger("reloadGrid", [{page:1}]);
};

function checkEnterKey(e) {
    //e is event object passed from function invocation
    var characterCode;  //literal character code will be stored in this variable

    if (e && e.which) { //if which property of event object is supported (NN4)
        e = e;
        characterCode = e.which;  //character code is contained in NN4's which property
    } else {
        characterCode = e.keyCode;  //character code is contained in IE's keyCode property
    }

    if (characterCode == 13) { //if generated character code is equal to ascii 13 (if enter key)
        return true;
    } else {
        return false;
    }
};


   //	fix for ie6
   function convertNullToEmptyString(value) {
   	if (value == null) {
   		return '';
   	} else {
   		return value;
   	}
};



function applyReadOnly(root) {
    $(root + ' input').attr('readonly', true);
    $(root + ' select').attr('disabled', true);
    $(root + ' select').addClass('disabled');
    $(root + ' textarea').attr('readonly', true);

    $(root + ' .ignore-readonly').removeAttr('disabled');
    $(root + ' .ignore-readonly').removeClass('disabled');
    $(root + ' .ignore-readonly').removeAttr('readonly');
}

    function initAddressAutoComplete(url, stateElement, suburbElement, postCodeElement)
    {
		$(suburbElement).autocomplete(url, {
			dataType: 'json',
			max: 40,
			extraParams: { state: function() { return $(stateElement).val(); } },
			parse: function(data) {
				var parsed = [];
				for (var i = 0; i < data.length; i++)
					parsed[i] = {
						data: [data[i].name, data[i].postcode],
						value: data[i].id,
						result: data[i].name
					};
				return parsed;
			},
			formatItem: function(data) {
				return convertNullToEmptyString(data[0]) + " (" + convertNullToEmptyString(data[1]) + ")";
			}
		})
        .result(function(event, data) {
			$(postCodeElement).val(convertNullToEmptyString(data[1]));
        })
        .focus(function() {
        	$(this).flushCache();
        });
	}

/* dialog functions */
function loadDialog(data, dialogDefaults) {

    var dialog;

    dialog = $('#dialog');

    //check whether to create dialog html
    if (dialog.length >0) {

        dialog.remove();
    }

    
    $("body").append('<div id="dialog" style="display: none"><span id="dialog-loading">Loading...</span><div id="dialog-content"></div></div>');

    dialog = $('#dialog');
    
    //create dialog
    dialog.dialog({
        resizable: false,
        modal: true
    });

    //override any custom settings
    if (dialogDefaults != undefined) {
        dialog.dialog("option", dialogDefaults);
    }

    dialog.find('#dialog-content').hide();
    dialog.find('#dialog-loading').show();

    //show dialog
    dialog.dialog('open');

    dialog.dialog('option', 'title', 'Loading...');

    if (data.buttonType == 'edit') {
        dialog.dialog('option', 'buttons',
	    {
	        'Cancel': function() {
	            $(this).dialog('close');
	        }

		    , 'Save & Close': function() {
		    
		        //if form has target, submit the form to the iframe (for file uploads)
		        if ($("#dialog form").attr('target') != '' ) {
		            $("#dialog form").submit();
		        
		        }
		        else
		        {
		            $.ajax({
		                url: $("#dialog form").attr('action'),
		                type: "POST",
		                data: $('#dialog form').serialize(),
		                success: function(data) {

		                    initDialog(dialog, data);

		                    data = $(data);

		                    var isValid = data.find('#page-isvalid').val();

		                    if (isValid == 'True') {

                                //run any javascript to be run on success
		                        dialog.find("#dialog-content").append(data.find("#dialog-success").html());
		                        
		                        dialog.dialog('close');
		                        
		                        showInfoMessage('Success', 'Job Comment saved.');
		                     
		                    }

		                }		            
		            }); //end ajax
		        }
		    }

	    });
    }
    else {
        dialog.dialog('option', 'buttons',
	    {
	        'Close': function() {
	            $(this).dialog('close');
	        }
	    });
    }

    $.ajax({
        url: data.url,
        success: function(result) {
            initDialog(dialog, result);
        }
    });
}



	function initDialog(dialog, data) {


	    dialog.find("#dialog-content").html($(data).find("div.dialog").html());

	    dialog.dialog('option', 'title', $(data).find("#page-title").val());

	    dialog.find('#dialog-content').show();
	    dialog.find('#dialog-loading').hide();

	    init('#dialog');

	}

	Date.prototype.toDDMMYYYY = function () { return isNaN(this) ? 'NaN' : [this.getDate() > 9 ? this.getDate() : '0' + this.getDate(), this.getMonth() > 8 ? this.getMonth() + 1 : '0' + (this.getMonth() + 1), this.getFullYear()].join('/') }
	Date.prototype.addDays = function (daysToAdd) { this.setDate(this.getDate() + daysToAdd); }
    String.prototype.fromDDMMYYYY = function () { var arr = this.split('/'); return new Date(arr[2], parseInt(arr[1] != '10' ? arr[1].replace('0', '') : arr[1]) - 1, arr[0]);}
        
