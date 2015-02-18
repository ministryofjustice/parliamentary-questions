//this allows access to the objects declared in trim_link.js
var trim_link;

(function(){
'use strict';

//assignment  & watchlist_dashboard/index - pages
var toggleSiblingContent = function(){
  $('details').each(function(i, el){
    var root = $(el),
      summary = root.find('span.link'),
      content = root.find('.reveal');

    summary.on('click', function(){
      content.toggleClass('closed');
      summary.toggleClass('opened');
    });
  });
};

//setting the commision status of the "commision" button on the dashboard / new tab
var setCommissionButtonStatus = function(form) {
    var enable = true;
    var button = form.find('.commission-button');

    form.find('select.required-for-commission,input.required-for-commission').each(function() {
      var value = $(this).val();
      var filled = (value !== "" && value !== null);

      enable = enable && filled;
    });


    if (enable === true) {
      button.removeAttr('disabled');
    } else {
      button.attr('disabled', 'disabled');
    }
};

// The "incrementBadge" shows the incremented New PQ's on /finance/questions page
var incrementBadge = function(id_of_navpill) {
  changeBadgeBy(id_of_navpill,1);
};
var decrementBadge = function(id_of_navpill) {
  changeBadgeBy(id_of_navpill,-1);
};
var changeBadgeBy = function(id_of_navpill, val) {
  var $badge = $(id_of_navpill).children('a').children('span');
  var curval = parseInt($badge.text(),10);
  var nextval = curval+val;
  if (nextval < 0) {
    nextval = 0;
  }
  $badge.text(nextval);
};

$(document).ready(function () {
  $('.datetimepicker input').datetimepicker({validateOnBlur:false,
                                             closeOnDateSelect:true,
                                             dayOfWeekStart: 1,
                                             format:'d/m/Y     H:i'});

  $('.datepicker input').datetimepicker({timepicker: false,
                                         validateOnBlur:false,
                                         closeOnDateSelect:true,
                                         dayOfWeekStart: 1,
                                         format:'d/m/Y'});

  $('.minister-select').select2({width:'250px'});
  $(".multi-select-action-officers").select2({width:'250px'});
  $(".single-select-dropdown").select2({width:'250px', allowClear: true});

//accept or reject tokenised PQ on assignment / index page
  $('#allocation_response_response_action_accept').click(function (){
    $('#reason-textarea').addClass('hide');
  });

  $('#allocation_response_response_action_reject').click(function (){
    $('#reason-textarea').removeClass('hide');
  });

  $('.form-commission').each(function() {
   setCommissionButtonStatus($(this));
  });

// commisioning a question and showing the success message on the dashboard page
  $(".form-commission")
    .on("ajax:success", function(){
      var pqid = $(this).data('pqid');
      var uin  = $(this).parents('*[data-pquin]').data('pquin');
      $('#pq-frame-'+pqid).replaceWith('<div class="alert success fade in">'+ uin +' commissioned successfully <button class="close" data-dismiss="alert">×</button></div>');
     incrementBadge('#db-filter-alloc-pend');
      decrementBadge('#db-filter-unalloc');
    }).on("ajax:error", function(e, xhr) {
      console.log(xhr.responseText);
    }).on('change', function(e) {
     setCommissionButtonStatus($(e.currentTarget));
    });

    $('#search_member').bind('ajax:before', function() {
      $(this).data('params', { name: $("#minister_name").val() });
    });

    $('#search_member').bind('ajax:success', function(e, data){
      $( "#members_result" ).replaceWith(data);
      $("#members_result_select").select2({width:'250px'});
      $('#members_result_select_link').bind('ajax:before', function() {
        var m_id = $("#members_result_select").val();
        var m_name = $("#members_result_select option:selected").data('name');
        $("#minister_member_id").val(m_id);
        $("#minister_name").val(m_name);
          return false;
        });
    });

    $('.answer-pq-link').on('ajax:success', function(e, data){
      var pq_id = $(this).data('id');
      var divToFill = "#answer-pq-" + pq_id;
      $( divToFill ).html(data);
    });

    // when clicking a calendar icon, open the calendar to the left of it
    // and if empty populate it with the current time,
    // unless it has class default-time, in which case set time to 10:00
    $('span.fa-calendar').on('click', function () {
        var picker = $(this).prev('input'), now, nowString;

        if (picker.val() === '') {
          now = new Date();
          if (picker.parent('.datepicker').length) {
            nowString = now.toLocaleString().substring(0,10);
          } else {
            if (picker.parent('.datetimepicker').hasClass('default-time')) {
              now.setHours(10);
              now.setMinutes(0);
            }
            nowString = now.toLocaleString().substring(0,16).replace(' ', '     ');
          }
          picker.val(nowString);
        }

        picker.datetimepicker('show');
    });

    $('.ao-reminder-link').on('ajax:success', function(e, data){
      $(this).after(data);
    });

  if($('.trim_area').length){
    trim_link.trimFileUpload();
  }
  if($('details').length){
    toggleSiblingContent();
  }

  $('.comm-header').on('click', function () {
    var pqid = $(this).data('pqid');
    var $caret = $(this).children('#comm-caret-' + pqid);
    $caret.toggleClass('fa-caret-right').toggleClass('fa-caret-down');
    $('#comm-details-' + pqid).toggleClass('start-hidden');
  });

  $('.progress-menu-item').on('click',function() {
    $('.progress-menu-data').hide();
    $('#' + $(this).attr('id') + '-data').show();
    $('.progress-menu-form').show();
  });

  $("#progress-menu-pq").addClass("activeTab");
  $("#progress-menu-pq-data").removeClass("start-hidden");

  /* PQ Details Page - Set styling when tab clicked */
  $("#progress-menu a").click(function() {
    var e="#"+$(this).attr("id");
    $("#progress-menu-pq, #progress-menu-trim, #progress-menu-fc, #progress-menu-com, #progress-menu-sub, #progress-menu-pod, #progress-menu-min, #progress-menu-answer").removeClass( "activeTab" ).addClass("inactiveTab");
    $(e).removeClass("inactiveTab").addClass("activeTab");
  });

  // Checkbox and radio button CSS state changes
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

  // Add/remove selected class
  $('.block-label').find('input[type=radio], input[type=checkbox]').click(function() {
    $('input:not(:checked)').parent().removeClass('selected');
    $('input:checked').parent().addClass('selected');
    $('.toggle-content').hide();
    var target = $('input:checked').parent().attr('data-target');
    $('#'+target).show();
  });

  // For pre-checked inputs, show toggled content
  var target = $('input:checked').parent().attr('data-target');
  $('#'+target).show();

});
}());
