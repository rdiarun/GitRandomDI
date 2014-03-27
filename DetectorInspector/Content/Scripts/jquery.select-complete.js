// Bradley Ford 2010
if (typeof jQuery == 'undefined') throw ("jQuery could not be found.");

(function($) {	
    $.fn.extend({
	    selectComplete: function() {
		    var settings = $.extend($.SelectComplete.defaults, arguments.length != 0 ? arguments[0] : {});

		    return this.each(function() {
			    new $.SelectComplete($(this), settings);
		    });
	    }
    });

    $.SelectComplete = function(selectElement, settings) {
        selectElement.data('lastKeyPress', 0);
        selectElement.data('text', null);

        selectElement.bind(($.browser.opera ? "keypress" : "keydown") + '.selectComplete', { settings: settings }, function(e) {       
            var keyCode = e.keyCode;
            var keyChar = String.fromCharCode(keyCode).toUpperCase();
            
            if ((keyCode > 47 && keyCode < 91) || keyCode == 32) {
                var el = $(e.target);
                
                var lastKeyPress = el.data('lastKeyPress');
                var text = el.data('text');
                    
                var now = new Date().getTime();
                
                if (text == null) {
                    text = keyChar.toUpperCase();
                } else if (now > lastKeyPress + settings.resetDelay) {
                    text = keyChar.toUpperCase();
                } else {
                    text += keyChar.toUpperCase();
                }

                el.data('lastKeyPress', now);
                el.data('text', text);

                var selectOptions = el[0].options;
                var optionCount = selectOptions.length;
                
                for (var i = 0; i < optionCount; i++) {
                    var optionText = selectOptions[i].text.toUpperCase();
                   
                    if (optionText.indexOf(text) == 0) {
                        el.val(selectOptions[i].value);
                        break;
                    }
                }
                
                return false;
            }    
        });
    };

    $.SelectComplete.defaults = {
	    resetDelay: 2000
    };
})(jQuery);
