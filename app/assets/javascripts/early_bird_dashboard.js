// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function () {
    "use strict";
    //Check Initial browser window size - apply sticky filter
    var win = $(this);
    if (win.width() > 991) {
        $('#filters').addClass('js-stick-at-top-when-scrolling');
    }

    // On browser window resize add/remove sticky filter
    $(window).on('resize', function () {
        if (win.width() > 991) {
            $('#filters').addClass('js-stick-at-top-when-scrolling');
        }
        else {
            $('#filters').removeClass('js-stick-at-top-when-scrolling');
        }
    });
});

