var document, $, trimLink, ga;

(function() {
  'use strict';

  var filterPreviewQuestions = function(text, state) {

    var textToSearch = new RegExp(text, 'i');
    var count = 0;
    var stateString = state ? ' <strong>' + state + '</strong> ' : ' ';

    $('#main ul li').each(function(i, li) {
      var questionText = $(li).text();
      if (textToSearch.test(questionText) && $(li).has('h2 span:contains("' + state + '")').length) {
        count++;
        $(li).css('display', 'block');
      } else {
        $(li).css('display', 'none');
      }
    });

    $('#count strong').text(count ? count : 'No');
    if (text) {
      $('#count span').html('new' + stateString + 'questions containing <strong>' + text + '</strong>');
    } else {
      $('#count span').html('new' + stateString + 'questions');
    }
  };

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
      var filled = (value !== '' && value !== null);
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

  //  +---------------------------------------------------------------------------+
  //  |  Question filtering                                                       |
  //  +---------------------------------------------------------------------------+

  var filterQuestions = function(){

    //  +---------------------------------------------------------------------------+

    var questionCounter = function(){

      var count = 0;

      $('#dashboard ul.questions-list li.question').each(function (i, li) {
        if ( $(li).has('a.question-uin').length && $(li).css("display") != "none" ) {
          count++;
        }
      });
      if ( count == 1 ) {
        $('#count').html('<strong>' + count + '</strong> <span>parlimentary question found</span>');
      }
      else {
        $('#count').html('<strong>' + count + '</strong> <span>parlimentary questions found</span>');
      }
    };

    //  +---------------------------------------------------------------------------+

    var showAllInProgress = function() {
      $('#dashboard ul.questions-list li.question').each(function (i, li) {
        $(li).css('display', 'block');
      });
    };

    //  +---------------------------------------------------------------------------+

    var filterByDateRange = function (filter, filterDate) {

      var questionDate = "";
      var questionDateLocation = "";

      if (filter == '.answer-from' || filter == '.answer-to') {
        questionDateLocation = ".answer-date";
      }
      else {
        questionDateLocation = ".deadline-date";
      }


      $('#dashboard ul.questions-list li.question').each(function (i, li){
        if ( $(li).has(questionDateLocation).length ) {
          if ( $(this).find(questionDateLocation).text().length > 0 ) {
            questionDate = $(this).find(questionDateLocation).text();
          }
          else if ( $(this).find(questionDateLocation).val().length > 0 ) {
            questionDate = $(this).find(questionDateLocation).val();
          }
        }
        else if ( $(li).css("display") != "none" ) {
          $(li).css('display', 'none');
        }

        var mQuestionDate = moment(questionDate, "DD/MM/YYYY");
        var mFilterDate = moment(filterDate, "DD/MM/YYYY");

        if ( (filter == ".answer-from") || (filter == ".deadline-from") && $(li).css("display") != "none" ) {
          if ( mQuestionDate.isBefore(mFilterDate) ) {
            $(li).css('display', 'none');
          }
        }
        else if ( (filter == ".answer-to") || (filter == ".deadline-to") && $(li).css("display") != "none" ) {
          if ( mQuestionDate.isAfter(mFilterDate) ) {
            $(li).css('display', 'none');
          }
        }
      });
    };

    //  +---------------------------------------------------------------------------+

    var filterByRadioButton = function (filter, value) {

      $('#dashboard ul.questions-list li.question').each(function (i, li){
        if ( $(li).has(filter).length ) {
          if ($(li).has(filter + ':contains("' + value + '")').length && $(li).css("display") != "none") {
            $(li).css('display', 'block');
          }
          else { $(li).css('display', 'none'); }
        }
        else { $(li).css('display', 'none'); }
      });
    };

    //  +---------------------------------------------------------------------------+

    var filterByKeyword = function (filter, value) {

      var escapedText = value.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
      var textToSearch = new RegExp(escapedText, 'i');

      $('#dashboard ul.questions-list li.question').each(function (i, li) {
        var questionText = $(li).text();
        if ( textToSearch.test(questionText) && $(li).css("display") != "none") {
          $(li).css('display', 'block');
        }
        else { $(li).css('display', 'none'); }
      });
    };

    //  +---------------------------------------------------------------------------+

    var getFilterValues = function(){
      if ( ( $('#answer-from').val() != undefined ) && ( $('#answer-from').val().trim().length > 0 ) ) {
        filterByDateRange(".answer-from", $('#answer-from').val());
      }
      if ( ( $('#answer-to').val() != undefined ) && ( $('#answer-to').val().trim().length > 0) ) {
        filterByDateRange(".answer-to", $('#answer-to').val());
      }
      if ( ( $('#deadline-from').val() != undefined ) && ( $('#deadline-from').val().trim().length > 0 ) ) {
        filterByDateRange(".deadline-from", $('#deadline-from').val());
      }
      if ( ( $('#deadline-to').val() != undefined ) && ( $('#deadline-to').val().trim().length > 0 ) ) {
        filterByDateRange(".deadline-to", $('#deadline-to').val());
      }
      if ($('input[name="flag"]:checked').val() != undefined){
        $('#flag .notice').show();
        filterByRadioButton(".flag", $("input[name='flag']:checked").val());
      }
      if ($('input[name="replying-minister"]:checked').val() != undefined){
        $('#replying-minister .notice').show();
        filterByRadioButton(".replying-minister", $('input[name="replying-minister"]:checked').val());
      }
      if ( $('input[name="policy-minister"]:checked').val() != undefined) {
        $('#policy-minister .notice').show();
        filterByRadioButton(".policy-minister", $('input[name="policy-minister"]:checked').val());
      }
      if ( $('input[name="question-type"]:checked').val() != undefined) {
        $('#question-type .notice').show();
        filterByRadioButton(".question-type", $('input[name="question-type"]:checked').val());
      }
      if ( ( $('#keywords').val() != undefined ) && ( $('#keywords').val().trim().length > 0 ) ) {
        filterByKeyword(".pq-question", $('#keywords').val());
      }
    };

    showAllInProgress();
    getFilterValues();
    questionCounter();
  };

  //  +---------------------------------------------------------------------------+
  //  |  Quick action filtering                                                       |
  //  +---------------------------------------------------------------------------+

  var quickActionSelections = function(){

    var questionIDsSelected = "";
    var selectionCount = 0;

    $('#dashboard .question .pq-header input[type="checkbox"]:checked').each(function() {
      questionIDsSelected = questionIDsSelected.concat($(this).val() + ",");
      selectionCount++;
    });

    if (selectionCount > '0') {
      // Remove trailing ',' from ID string;
      questionIDsSelected = questionIDsSelected.slice(0,-1);

      $('#chosenQestions').val(questionIDsSelected);
      $('#selectionCount').html("Export " + selectionCount + " selected PQs?");
    }
    else { $('#selectionCount').html("No PQs selected"); }

    console.log("===========================================");
    console.log("questionIDsSelected: " + questionIDsSelected);
    console.log("===========================================");
    console.log("Number selected: " + selectionCount);
    console.log("===========================================");
    console.log("Actual form string: " + $('#chosenQestions').val());
    console.log("===========================================");

  };

  //==========================================================================

  $(document).ready(function () {

    // Set today's date
    var today = moment().format('DD/MM/YYYY').toString();

    // if the page has rejection details, make them collapsible
    // applies to /assignment and /watchlist/preview pages
    $('.reveal > span').each(enableDetailsToggle);

    // Form behaviour: checkbox and radio button CSS state changes
    $('.block-label').each(function() {
      // Add focus
      $('.block-label input').focus(function() {
        $('label[for="' + this.id + '"]').addClass('add-focus');
      }).blur(function() {
        $('label').removeClass('add-focus');
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
      $('#' + target).show();
    });


    if (document.getElementById('assignment') || document.getElementById('preview')) {
      // This is the assignment page. As it is typically seen on IE7
      // we need to avoid other unneccessary initialisations as they
      // break the page

      $('nav').hide();

      // open the reject justification form when Reject is selected
      // and hide it when Accept is selected
      $('#allocation_response_response_action_accept').on('click', function (){
        $('#reason-textarea').addClass('hide');
      });
      $('#allocation_response_response_action_reject').on('click', function (){
        $('#reason-textarea').removeClass('hide');
      });

      $('#preview input[type="text"]').on('keyup', function() {
        filterPreviewQuestions(
            $('#filters input[type="text"]').val(),
            $('#filters input[type="radio"]:checked').siblings('span').text()
        );
      });

      $('#preview #filters input').on('click', function(event) {
        if ($(event.target).is(':checked')) {
          $(event.target).siblings('input').attr('checked', false);
          filterPreviewQuestions(
              $('#filters input[type="text"]').val(),
              $(event.target).next().text()
          );
        }
        else{
            filterPreviewQuestions(
                $('#filters input[type="text"]').val(),
                ''
            );
        }
      });

      $('.clearFilter').on('click', function(event) {
        $('.filter-box div').children('input').attr('checked', false);
        $('#filters input[type="text"]').val(' ');
        filterPreviewQuestions($('#filters input[type="text"]').val(),
                               $(event.target).next().text());
      });


    } else {
      // all other pages

      // set up any date pickers on the page
      $('.datetimepicker input').datetimepicker({validateOnBlur: false,
                                                 scrollMonth: false,
                                                 closeOnDateSelect: true,
                                                 dayOfWeekStart: 1,
                                                 format: 'd/m/Y     H:i'});

      // set up any datetime pickers on the page
      $('.datepicker input').datetimepicker({timepicker: false,
                                             scrollInput: false,
                                             scrollMonth: false,
                                             validateOnBlur: false,
                                             closeOnDateSelect: true,
                                             dayOfWeekStart: 1,
                                             format: 'd/m/Y'});
      // enable select2 drop-boxes on various select controls
      $('.minister-select').select2({width: '250px'});
      $('.multi-select-action-officers').select2({width: '250px'});
      $('.single-select-dropdown').select2({width: '250px', allowClear: true});

      // on the dashboard, enable the Commission button only if the required fields are non-empty
      $('.form-commission').each(function() {
       setCommissionButtonStatus($(this));
      });


      // Dashboard - Quick Action Export
      $('#quick-action-export').on('ajax:success', function(e, data) {
          alert("JS: quick-action-export returns Success!");
        $(this).replaceWith(data);
        //  $(this).after(data);
      }).on('ajax:error', function(e, xhr) {
          // the data passed to the backend was invalid
          alert("JS: quick-action-export returns error!");
          var errorText = xhr.status === 400 ?
              'Invalid input. Bad Data.' :
              'Very Bad data.';
          $(this).find('.quick-action-export-error-message')
              .text(errorText)
              .css('display', 'inline-block');
      });


      // commisioning a question and showing the success message on the dashboard page
      $('.form-commission')
        .on('ajax:success', function(){
          // if the question was successfully commission, then hide it and replace with
          // a success message
          var pqid = $(this).data('pqid');
          var uin = $(this).parents('*[data-pquin]').data('pquin');
          $('#pq-frame-' + pqid).replaceWith('<div class="pq-msg-success fade in">' + uin + ' commissioned successfully <button class="close" data-dismiss="alert">×</button></div>');
          // on the right-hand filter panel, increment the number of No Eesponse questions
          incrementBadge('#db-filter-alloc-pend');
          // and decrement the number of unallocated
          decrementBadge('#db-filter-unalloc');
        }).on('ajax:error', function(e, xhr) {
          // the data passed to the backend was invalid
          var errorText = xhr.status === 422 ?
            'Invalid input. Please correct and commission again.' :
            'Internal error. Please try again in a few minutes or contact support.';
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
              nowString = now.toLocaleString().substring(0, 10);
          } else {
            if (picker.parent('.datetimepicker').hasClass('default-time')) {
              now.setHours(11);
              now.setMinutes(0);
            }
            nowString = now.toLocaleString().substring(0, 16).replace(' ', '     ');
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
        var filesSelected = $('#pq_trim_link_attributes_file').prop('files');
        if (filesSelected.length) {
          ga('send', 'event', 'trim upload from details page', 'submit', $('h2').first().text());
        }
      });

    }

    // +---------------------------------------------------------------------------+
    // |  Filtering event listeners                                                |
    // +---------------------------------------------------------------------------+

    $('#dashboard #filters input').change(function (event) {
      if (
              $(event.target).is('#answer-from') ||
              $(event.target).is('#answer-to') ||
              $(event.target).is('#deadline-from') ||
              $(event.target).is('#deadline-to')
      )
      {
        filterQuestions();
      }
    });

   $('#dashboard #filters input').on('click', function (event) {

      // = Answer date 'Today' button clicked: set 'to' and 'from' values to today's date. =
      if ($(event.target).is('#answer-date-today')) {
        $('#answer-from').val(today) && $('#answer-to').val(today);
      }
      // = Deadline date 'Today' button clicked: set 'to' and 'from' values to today's date. =
      else if ($(event.target).is('#deadline-date-today')) {
        $('#deadline-from').val(today) && $('#deadline-to').val(today);
      }
      // = Answer date 'Clear' button clicked: empty the textbox fields. =
      else if ($(event.target).is('#clear-answer-filter')) {
        $('#answer-from').val('') && $('#answer-to').val('');
      }
      // = Deadline date 'Clear' button clicked: empty the textbox fields. =
      else if ($(event.target).is('#clear-deadline-filter')) {
        $('#deadline-from').val('') && $('#deadline-to').val('');
      }

      // Is it a "collapse" button ?
      else if ( ($(event.target).prop('class') === "view open") || ($(event.target).prop('class') === "view closed")){
        // Toggle the radio button list show / hide.
        $('#' + $(event.target).closest('.filter-box').prop('id') + ' .collapsed').toggle();
        // Toggle the v ^ button icon.
        $('#' + $(event.target).closest('.filter-box').prop('id') + ' input.view').toggleClass("open closed");
      }

      // = Keyword 'Clear' button clicked: empty the textbox field. =
      else if ($(event.target).is('#clear-keywords-filter')) {
        $('#keywords').val('');
      }

      // Is it a checkbox set "Clear" button ?
      else if ( $(event.target).val() === "Clear" && $(event.target).prop('id') != "clear-keywords-filter" ){
        // Find the filterbox that triggered the event and uncheck the radio button
        $('input[name="' + $(event.target).closest('.filter-box').prop('id') + '"]').removeAttr('checked');
        // Now the Radio buttons are clear, remove the '1 selected' notice.
        $('#' + $(event.target).closest('.filter-box').prop('id') + ' .notice').hide();
      }

      // = Run the filtering functions. =
      filterQuestions();
    });

    // = Keyword textbox character entered. =
    $('#dashboard #filters input').on('keyup', function (event) {
      if ($(event.target).is('#keywords')) {
        filterQuestions();
      }
    });

    // +---------------------------------------------------------------------------+
    // |  Quick action event listeners                                             |
    // +---------------------------------------------------------------------------+

    $('#dashboard #quick-links #csvExportButton').on('click', function (event) {
      $('#' + $(event.target).closest('form').prop('id') + ' .collapsed').toggle();
      quickActionSelections();
    });

    $('#cancel-export').on('click', function (event) {
      $('#csvExport .content.collapsed').toggle();
    });

    $('#dashboard #select-all').on('click', function (event) {
      if ( $('#select-all').prop('checked') ) {
        console.log("This has been checked");
        $('#dashboard .question .pq-header').each(function() {
          $('input[type="checkbox"]').prop('checked', true);
        });
      }
      // Unchecked checked
      else {
        console.log("This has been UN-checked");
        $('#dashboard .question .pq-header').each(function() {
          $('input[type="checkbox"]').prop('checked', false);
        });
      }
    });

  });
}());
