/* Dirty Data Check - By Madhukar Reddy Gurram
* Watched elements are text, radio, checkbox, hidden, file and textarea. You can add more below.
* Use class 'ignore-changes' to ignore any elements you do not want to watch.
* Use isDataDirty() to check the status and getDirtyData() to get an array of changed element id values.
* Implement function dirtyDataAlert() on your page which will be called on page unload if dirty data is present.
*/

var _isDirty = false;
var _dirtyElemIdArr = new Array();

function watchForChanges() {
    // add more elements here - input[type='password'] ?
    $("input[type='text'],input[type='radio'],input[type='checkbox'],input[type='hidden'],input[type='file'],select,textarea")
		.not(".ignore-changes")
		.change(function () {
		    _isDirty = true;
		    if ($(this).attr('id').length != 0)
		        _dirtyElemIdArr.push($(this).attr('id'));
		});
    $(':reset,:submit').bind('click', function (event) {
        _isDirty = false;
        _dirtyElemIdArr = new Array();
    });
}

function isDataDirty() {
    return _isDirty;
}

function getDirtyData() {
    return _dirtyElemIdArr;
}

function dirtyDataAlert() {
    var form = $('#edit-form')[0];
    if (confirm("You have some unsaved changes. Press OK to save or Cancel to continue without saving.")) {

        form.submit();
    }

}

function toggleTabs(show) {
    
}

$(document).ready(function () {
    watchForChanges();
    toggleTabs(true);
});

//$(document).unload(function() {});

window.onbeforeunload = function () {
    if (typeof dirtyDataAlert == "function" && isDataDirty())
        dirtyDataAlert();
}