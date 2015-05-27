(function() {
  'use strict';

  // make detail blocks toggleable
  var enableDetailsToggle = function(i, el) {
    var $root = $(el);
    var $content = $root.next('.reveal > div');

    $root.on('click', function(){
      $content.toggleClass('closed');
      $root.toggleClass('opened');
    });
  };

  // check that the various fields on a single PQ on the dashboard are valid
  var isValidDashboardPq = function($form) {
    var validSoFar = true;
    var $dateFields = $form.find('.datepicker input');
    var $dateTimeFields = $form.find('.datetimepicker input');

    // check if required fields have content
    $form.find('select.required-for-commission,input.required-for-commission').each(function() {
      var value = $(this).val();
      var filled = (value !== "" && value !== null);
      validSoFar = validSoFar && filled;
    });

    if (!validSoFar) { return false; }

    // check if date fields have the correct format
    $dateFields.each(function(index, field) {
      if (!field.value.match(/^\s*[0-3]?[0-9]\/[01]?[0-9]\/(19|20)?[0-9]{2}\s*$/)) {
        validSoFar = false;
      }
    });

    if (!validSoFar) { return false; }

    // check if the datetime fields have the correct format
    $dateTimeFields.each(function(index, field) {
      if (!field.value.match(/^\s*[0-3]?[0-9]\/[01]?[0-9]\/(19|20)?[0-9]{2}\s+[0-2]?[0-9]:[0-5][0-9]\s*$/)) {
        validSoFar = false;
      }
    });

    return validSoFar;
  };

  // on the Dashboard (/dashboard), only enable the Commission button if
  // the mandatory fields are valid
  var setCommissionButtonStatus = function($form) {
    var $button = $form.find('.commission-button');
    if (isValidDashboardPq($form)) {
      $button.removeAttr('disabled');
    } else {
      $button.attr('disabled', 'disabled');
    }
  };

  // The 3 functions below increment, decrement or change the number of New PQ's
  // on the filter box
  var incrementBadge = function(idOfNavpill) {
    changeBadgeBy(idOfNavpill, 1);
  };

  var decrementBadge = function(idOfNavpill) {
    changeBadgeBy(idOfNavpill, -1);
  };

  var changeBadgeBy = function(idOfNavpill, val) {
    var $badge = $(idOfNavpill).children('a').children('span');
    var curval = parseInt($badge.text(), 10);
    var nextval = curval + val;
    if (nextval < 0) {
      nextval = 0;
    }
    $badge.text(nextval);
  };

  //==========================================================================

  $(document).ready(function () {

    // if the page has rejection details, make them collapsible
    // applies to /assignment and /watchlist/preview pages
    $('.reveal > span').each(enableDetailsToggle);

    // Form behaviour: checkbox and radio button CSS state changes
    $(".block-label").each(function() {
      // Add focus
      $(".block-label input").focus(function() {
        $("label[for='" + this.id + "']").addClass("add-focus");
      }).blur(function() {
        $("label").removeClass("add-focus");
      });
      // Add selected class
      $('input:checked').parent().addClass('selected');
    });

    // Form behaviour: add/remove selected class
    $('.block-label').find('input[type=radio], input[type=checkbox]').click(function() {
      $('input:not(:checked)').parent().removeClass('selected');
      $('input:checked').parent().addClass('selected');
      $('.toggle-content').hide();
      var target = $('input:checked').parent().attr('data-target');
      $('#'+target).show();
    });

    if (document.getElementById('assignment')) {
      // This is the assignment page. As it is typically seen on IE7
      // we need to avoid other unneccessary initialisations as they
      // break the page

      // open the reject justification form when Reject is selected
      // and hide it when Accept is selected
      $('#allocation_response_response_action_accept').on('click', function (){
        $('#reason-textarea').addClass('hide');
      });
      $('#allocation_response_response_action_reject').on('click', function (){
        $('#reason-textarea').removeClass('hide');
      });

    } else {
      // all other pages

      // set up any date pickers on the page
      $('.datetimepicker input').datetimepicker({validateOnBlur:false,
                                                 scrollMonth: false,
                                                 closeOnDateSelect:true,
                                                 dayOfWeekStart: 1,
                                                 format:'d/m/Y     H:i'});

      // set up any datetime pickers on the page
      $('.datepicker input').datetimepicker({timepicker: false,
                                             scrollInput: false,
                                             scrollMonth: false,
                                             validateOnBlur:false,
                                             closeOnDateSelect:true,
                                             dayOfWeekStart: 1,
                                             format:'d/m/Y'});
      // enable select2 drop-boxes on various select controls
      $('.minister-select').select2({width:'250px'});
      $('.multi-select-action-officers').select2({width:'250px'});
      $('.single-select-dropdown').select2({width:'250px', allowClear: true});

      // on the dashboard, enable the Commission button only if the required fields are non-empty
      $('.form-commission').each(function() {
       setCommissionButtonStatus($(this));
      });

      // commisioning a question and showing the success message on the dashboard page
      $(".form-commission")
        .on("ajax:success", function(){
          // if the question was successfully commission, then hide it and replace with
          // a success message
          var pqid = $(this).data('pqid');
          var uin  = $(this).parents('*[data-pquin]').data('pquin');
          $('#pq-frame-'+pqid).replaceWith('<div class="pq-msg-success fade in">'+ uin +' commissioned successfully <button class="close" data-dismiss="alert">×</button></div>');
          // on the right-hand filter panel, increment the number of No Eesponse questions
          incrementBadge('#db-filter-alloc-pend');
          // and decrement the number of unallocated
          decrementBadge('#db-filter-unalloc');
        }).on("ajax:error", function(e, xhr) {
          // the data passed to the backend was invalid
          var errorText = xhr.status === 422 ?
            "Invalid input. Please correct and commission again." :
            "Internal error. Please try again in a few minutes or contact support.";
          $(this).find('.commissioning-error-message')
            .text(errorText)
            .css('display', 'inline-block');
          }).on('change', function(e) {
         // when the form is modified, check if all the mandatory fields are set
         // so that the Commission button is enabled
         setCommissionButtonStatus($(e.currentTarget));
        });

      // when clicking a calendar icon, open the calendar to the left of it
      // and if empty populate it with the current time,
      // (unless it has class default-time, in which case set time to 11:00)
      $('span.fa-calendar').on('click', function () {
        var picker = $(this).prev('input'), now, nowString;
        if (picker.val() === '') {
          now = new Date();
          if (picker.parent('.datepicker').length) {
              nowString = now.toLocaleString().substring(0,10);
          } else {
            if (picker.parent('.datetimepicker').hasClass('default-time')) {
              now.setHours(11);
              now.setMinutes(0);
            }
            nowString = now.toLocaleString().substring(0,16).replace(' ', '     ');
          }
          picker.val(nowString);
        }
        picker.datetimepicker('show');
      });

      // on successful reminder sent, display the data received from the
      // ajax call
      $('.ao-reminder-link').on('ajax:success', function(e, data){
        $(this).after(data);
      });

      // set up the trim file upload controls, if present
      trimLink.setUpTrimControls();


      // throw a google analytics event on trim link upload from dashboard
      $('.form-add-trim-link').on('submit', function() {
        var pquin = $(this).parents('li').first().data('pquin');
        ga('send', 'event', 'trim upload from dashboard', 'submit', pquin.toString());
      });

      $('.progress-menu-form').on('submit', function() {
        var files_selected = $('#pq_trim_link_attributes_file').prop('files');
        if (files_selected.length) {
          ga('send', 'event', 'trim upload from details page', 'submit', $('h2').first().text());
        }
      });
    }
  });
}());
