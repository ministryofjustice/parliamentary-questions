(function() {
  'use strict';

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
      $button.attr('aria-disabled', 'false');
      $button.prop('disabled', false);
    } else {
      $button.attr('aria-disabled', 'true');
      $button.attr('disabled', 'disabled');
    }
  };

  var setAriaExpandedBoolean = function($clickedButton) {
    if ($clickedButton.attr('aria-expanded') === 'true') {
      $clickedButton.attr('aria-expanded', 'false');
    } else {
      $clickedButton.attr('aria-expanded', 'true');
    }
  };

  // Quick action filtering --

  var $selectAll = $('#select-all');

  var selectedPQCount = function(){
    var selectionCount = 0;
    $('.pq-header input[type="checkbox"]:checked').each(function() {
      selectionCount++;
    });
    if (selectionCount > '0') {
      var selectionMessage = ( selectionCount == 1 ) ? " PQ selected" : " PQs selected";
      $('.selectionCount').html(selectionCount + selectionMessage);
      $('#do-export').prop('disabled', false);
      $('#do-reminders').prop('disabled', false);
      if (
        ($('#qa_edit_deadline_date').val().length == 10 ||
        $('#qa_edit_draft_date').val().length == 10 ||
        $('#qa_edit_pod_date').val().length == 10 ||
        $('#qa_edit_minister_date').val().length == 10 ||
        $('#qa_edit_answered_date').val().length == 10) && $('#editDates .selectionCount').text().trim() != 'No PQs selected'
      ){
        $('#do-edit').prop("disabled", false); // Enable 'Edit' button.
      }
    }
    else {
      $('.selectionCount').html("No PQs selected");
      $('#do-export').attr("disabled", "disabled");
      $('#do-edit').attr("disabled", "disabled");
      $('#do-reminders').attr("disabled", "disabled");
    }
  };

  var selectIndividualPQ = function(){
    if ( $selectAll.prop('checked') ) {
      $selectAll.prop('checked', false);
    }
    selectedPQCount();
  };

  var selectAllPQs = function(){
    if ( $selectAll.prop('checked') ) {
      $('li.question').each(function (i, li) {
        if ( $(li).css("display") != "none" ) {
          $(this).find('.pq-select').prop('checked', true);
        }
      });
    }
    else { $('.pq-select').prop('checked', false); }
    selectedPQCount();
  };

  var getSelectedPQs = function(){
    var uinSelected = "";
    $('#dashboard .question .pq-header input[type="checkbox"]:checked').each(function() {
      uinSelected = uinSelected.concat($(this).prop('id') + ",");
    });
    uinSelected = uinSelected.slice(0,-1);
    $('#pqs_comma_separated').val(uinSelected);
    $('#pqs_comma_separated_for_dates').val(uinSelected);
    $('#pqs_comma_sep_for_drafts').val(uinSelected);
  };

 //  Question filtering --

  var filterQuestions = function(){

    var $answerFrom = $('#answer-from');
    var $answerTo = $('#answer-to');
    var $deadlineFrom = $('#deadline-from');
    var $deadlineTo = $('#deadline-to');
    var $filterCheckbox = 'input[type="checkbox"]';
    var $keywordSearch = $('#keywords');
    var $policyMinisterRdo = $('input[name="policy-minister"]:checked');
    var $question = $('li.question');
    var $replyingMinisterRdo = $('input[name="replying-minister"]:checked');
    var $statusRdo = $('input[name="flag"]:checked');
    var $typeRdo = $('input[name="question-type"]:checked');

    var questionCounter = function(){
      var totalQuestionCount = 0;
      var filteredQuestionCount = 0;
      $question.each(function (i, li) {
        // Count the total number of questions
        if ( $(li).has('.question h2').length ) {
          totalQuestionCount++;
        }
      });
      $question.each(function (i, li) {
        // Count the number of filtered questions
        if ( $(li).has('.question h2').length && $(li).css("display") != "none" ) {
          filteredQuestionCount++;
        }
      });
      var countMessage = ( filteredQuestionCount == 1 ) ? "question" : "questions";
      $('#count').html("<strong>" + filteredQuestionCount + "</strong> <span>parliamentary " + countMessage + " out of <strong>" + totalQuestionCount + "</strong>.</span>");
    };

    var showAllInProgress = function() {
      $question.each(function (i, li) {
        $(li).css('display', 'block');
      });
    };

    var filterByDateRange = function (filter, filterDate) {
      var questionDate = "";
      var questionDateLocation = "";
      if (filter == '.answer-from' || filter == '.answer-to') {
        questionDateLocation = ".answer-date";
      }
      else {
        questionDateLocation = ".deadline-date";
      }
      $question.each(function (i, li){
        if ( $(li).has(questionDateLocation).length ) {
          if ( $(this).find(questionDateLocation).text().length > 0 ) {
            questionDate = $(this).find(questionDateLocation).text();
          }
          else if ( $(this).find(questionDateLocation).val().length > 0 ) {
            questionDate = $(this).find(questionDateLocation).val();
          }
        }
        else if ( $(li).css("display") != "none" ) {
          $(this).find($filterCheckbox).prop('checked', false);
          $(li).css('display', 'none');
        }
        var mQuestionDate = moment(questionDate, "DD/MM/YYYY");
        if (questionDateLocation == ".deadline-date") {
          mQuestionDate = moment(questionDate, "YYYY-MM-DD");
        }
        var mFilterDate = moment(filterDate, "DD/MM/YYYY");
        if ( (filter == ".answer-from") || (filter == ".deadline-from") && $(li).css("display") != "none" ) {
          if ( mQuestionDate.isBefore(mFilterDate) ) {
            $(this).find($filterCheckbox).prop('checked', false);
            $(li).css('display', 'none');
          }
        }
        else if ( (filter == ".answer-to") || (filter == ".deadline-to") && $(li).css("display") != "none" ) {
          if ( mQuestionDate.isAfter(mFilterDate) ) {
            $(this).find($filterCheckbox).prop('checked', false);
            $(li).css('display', 'none');
          }
        }
      });
    };

    var filterByRadioButton = function (filter, value) {
      $question.each(function (i, li){
        if( value == "None" ) {
          if ( $(li).has(filter).length && $(li).css("display") != "none" ) {
            $(this).find($filterCheckbox).prop('checked', false);
            $(li).css('display', 'none');
          }
        }
        else {
          if ( $(li).has(filter).length ) {
            if ($(li).has(filter + ':contains("' + value + '")').length && $(li).css("display") != "none") {
              $(li).css('display', 'block');
            }
            else {
              $(this).find($filterCheckbox).prop('checked', false);
              $(li).css('display', 'none');
            }
          }
          else {
            $(this).find($filterCheckbox).prop('checked', false);
            $(li).css('display', 'none');
          }
        }
      });
    };

    var filterByKeyword = function (filter, value) {
      var escapedText = value.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
      var textToSearch = new RegExp(escapedText, 'i');
      $question.each(function (i, li) {
        var questionText = $(li).text();
        if ( textToSearch.test(questionText) && $(li).css("display") != "none") {
          $(li).css('display', 'block');
        }
        else {
          $(this).find($filterCheckbox).prop('checked', false);
          $(li).css('display', 'none');
        }
      });
    };

    // Trigger filtering only in inputs with a value.
    var getFilterValues = function(){
      if ( ( $answerFrom.val() != undefined ) && ( $answerFrom.val().trim().length > 0 ) ) {
        filterByDateRange(".answer-from", $('#answer-from').val());
      }
      if ( ( $answerTo.val() != undefined ) && ( $answerTo.val().trim().length > 0) ) {
        filterByDateRange(".answer-to", $('#answer-to').val());
      }
      if ( ( $deadlineFrom.val() != undefined ) && ( $deadlineFrom.val().trim().length > 0 ) ) {
        filterByDateRange(".deadline-from", $('#deadline-from').val());
      }
      if ( ( $deadlineTo.val() != undefined ) && ( $deadlineTo.val().trim().length > 0 ) ) {
        filterByDateRange(".deadline-to", $('#deadline-to').val());
      }
      if ($statusRdo.val() != undefined){
        $('#flag .notice').show();
        filterByRadioButton(".flag", $statusRdo.val());
      }
      if ($replyingMinisterRdo.val() != undefined){
        $('#replying-minister .notice').show();
        filterByRadioButton(".replying-minister", $replyingMinisterRdo.val());
      }
      if ( $policyMinisterRdo.val() != undefined) {
        $('#policy-minister .notice').show();
        filterByRadioButton(".policy-minister", $policyMinisterRdo.val());
      }
      if ( $typeRdo.val() != undefined) {
        $('#question-type .notice').show();
        filterByRadioButton(".question-type", $typeRdo.val());
      }
      if ( ( $keywordSearch.val() != undefined ) && ( $keywordSearch.val().trim().length > 0 ) ) {
        filterByKeyword(".pq-question", $keywordSearch.val());
      }
    };
    $selectAll.prop('checked', false);
    showAllInProgress();
    getFilterValues();
    questionCounter();
    selectedPQCount();
  };

//  +---------------------------------------------------------------------------+

  $(document).ready(function () {

    // Set today's date
    var today = moment().format('DD/MM/YYYY').toString();

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
      // we need to avoid other unnecessary initialisations as they
      // break the page

      $('.navbar').hide();

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

      // set up any datetime pickers on the page
      $('.datepicker input').datetimepicker({
        closeOnDateSelect: true,
        dayOfWeekStart: 1,
        format: 'd/m/Y',
        scrollInput: false,
        scrollMonth: false,
        timepicker: false,
        validateOnBlur: false
      });

      // set up any date pickers on the page
      $('.datetimepicker input').datetimepicker({
        closeOnDateSelect: true,
        dayOfWeekStart: 1,
        defaultTime: '11:00',
        format: 'd/m/Y H:i',
        scrollMonth: false,
        validateOnBlur: false
      });

      // enable select2 drop-boxes on various select controls
      $('.multi-select-action-officers').select2({width: '250px'});

      // on the dashboard, enable the Commission button only if the required fields are non-empty
      $('.form-commission').each(function() {
       setCommissionButtonStatus($(this));
      });

      // Commissioning a question and showing the success message on the dashboard page
      $('.form-commission')
        .on('ajax:success', function(){
          // if the question was successfully commission, then hide it and replace with
          // a success message
          var pqid = $(this).data('pqid');
          var uin = $(this).parents('*[data-pquin]').data('pquin');

          $('#pq-frame-' + pqid).html('<div class="pq-msg-success fade in">' + uin + ' commissioned successfully <button class="close" data-dismiss="alert">×</button></div>');

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
      $('.ao-reminder-link').on('ajax:success', function(e) {
        var data = e.originalEvent.detail[2].response;
        $(this).after(data);
      });
    }

    //  Filtering events
    var $quickActions = $('#quick-links input');
    var $dashboardFilters = $('#filters input');

    // Select individual questions for export
    $('#select-all-questions input[type="checkbox"]').on('click', function () {
      selectAllPQs();
    });

    // Select all questions for export
    $('.pq-header input[type="checkbox"]').on('click', function () {
      selectIndividualPQ();
    });

    $quickActions.on('click', function (event) {

      // toggle the aria-expanded true:false
      setAriaExpandedBoolean($(event.target));

      // collapse/expand quick actions
      if ( $(event.target).is('#qa-edit-dates') ) {
        $('#' + $(event.target).closest('form').prop('id') + ' .content.collapsed').toggle();
        $('#' + $('#qa-export-csv').closest('form').prop('id') + ' .content.collapsed').hide();
        $('#' + $('#qa-draft-reminders').closest('form').prop('id') + ' .content.collapsed').hide();
        $('#qa-export-csv, #qa-draft-reminders').attr('aria-expanded', 'false');
      }
      else if ( $(event.target).is('#qa-export-csv') ) {
        $('#' + $(event.target).closest('form').prop('id') + ' .content.collapsed').toggle();
        $('#' + $('#qa-edit-dates').closest('form').prop('id') + ' .content.collapsed').hide();
        $('#' + $('#qa-draft-reminders').closest('form').prop('id') + ' .content.collapsed').hide();
        $('#qa-edit-dates, #qa-draft-reminders').attr('aria-expanded', 'false');
      }
      else if ( $(event.target).is('#qa-draft-reminders') ) {
        $('#' + $(event.target).closest('form').prop('id') + ' .content.collapsed').toggle();
        $('#' + $('#qa-edit-dates').closest('form').prop('id') + ' .content.collapsed').hide();
        $('#' + $('#qa-export-csv').closest('form').prop('id') + ' .content.collapsed').hide();
        $('#qa-edit-dates, #qa-export-csv').attr('aria-expanded', 'false');
      }
      else if ( $(event.target).is('.qa-cancel') ) {
        $('#qa-draft-reminders, #qa-edit-dates, #qa-export-csv').attr('aria-expanded', 'false');
        $('#' + $(event.target).closest('form').prop('id') + ' .content.collapsed').toggle();
        $('#' + $(event.target).closest('form').prop('id') + ' .content.collapsed').siblings('input').focus();
      }
      else if ( $(event.target).is('#do-export') || $(event.target).is('#do-edit') || $(event.target).is('#do-reminders') ) {
        getSelectedPQs();
      }
    });

    $quickActions.on("change", function (event) {
      //  Quick Action: Edit Dates ~ Check at least one date and PQ selected
      if (
        ($(event.target).is('#qa_edit_deadline_date') && $('#qa_edit_deadline_date').val().length == 16 ||
        $(event.target).is('#qa_edit_draft_date') && $('#qa_edit_draft_date').val().length == 16 ||
        $(event.target).is('#qa_edit_pod_date') && $('#qa_edit_pod_date').val().length == 16 ||
        $(event.target).is('#qa_edit_minister_date') && $('#qa_edit_minister_date').val().length == 16 ||
        $(event.target).is('#qa_edit_answered_date') && $('#qa_edit_answered_date').val().length == 16) && $('#editDates .selectionCount').text().trim() != 'No PQs selected'
      ){
        $('#do-edit').prop("disabled", false); // Enable 'Edit' button.
      }
      else {
        $('#do-edit').prop("disabled", true); // Disable 'Edit' button.
      }
    });

    // Trigger date picker events
    $dashboardFilters.on("change", function () {
      filterQuestions();
    });

    $dashboardFilters.on('click', function (event) {
      // Today date buttons clicked.
      if ( $(event.target).is('#answer-date-today') ) {
        $( '#answer-from').val(today) && $('#answer-to').val(today);
      }
      else if ( $(event.target).is('#deadline-date-today') ) {
        $('#deadline-from').val(today) && $('#deadline-to').val(today);
      }
      // Clear button actions.
      else if ($(event.target).is('#clear-answer-filter')) {
        $('#answer-from').val('') && $('#answer-to').val('');
      }
      else if ($(event.target).is('#clear-deadline-filter')) {
        $('#deadline-from').val('') && $('#deadline-to').val('');
      }
      else if ( $(event.target).val() == "Clear" && $(event.target).prop('id') != "clear-keywords-filter" ){
        // Uncheck radio buttons.
        $('input[name="' + $(event.target).closest('.filter-box').prop('id') + '"]').prop("checked", false);
        // Hide the "1 selected" notice.
        $('#' + $(event.target).closest('.filter-box').prop('id') + ' .notice').hide();
      }
      else if ($(event.target).is('#clear-keywords-filter')) {
        $('#keywords').val('');
      }
      // Toggle filter box view
      else if (($(event.target).prop('class') === "view open") || ($(event.target).prop('class') === "view closed")){

        // toggle the aria-expanded true:false
        setAriaExpandedBoolean($(event.target));

        // Show/hide filter list.
        $('#' + $(event.target).closest('.filter-box').prop('id') + ' .collapsed').toggle();
        // Show/hide button icon.
        $('#' + $(event.target).closest('.filter-box').prop('id') + ' input.view').toggleClass("open closed");
      }
      filterQuestions();
    });

    $dashboardFilters.on('keyup', function (event) {
      if ($(event.target).is('#keywords')) {
        filterQuestions();
      }
    });
  });
}());
