(function(){
'use strict';

//function to upload file to trim
var trimFileUpload = function() {
	$('.trim-links-form').each(function(i, area){
		var container = $(area),
			message_container = container.find('.tr5-message'),
			message_icon = message_container.find('.fa'),
			upload_message = message_icon.siblings('.message'),
			actions = container.find('.tr5-actions'),
			choose_button = container.find('.button-choose'),
			form = container.find('form'),
			file_field = form.find('.trim-file-chooser'),
			cancel_button = form.find('.button-cancel'),
			status_messages = {
				selected : {
					message : 'File selected',
					classname : 'fa fa-check-circle'
				},
				uploading : {
					message : 'Uploading',
					classname : 'fa fa-spin fa-circle-o-notch'
				},
				success : {
					classname : 'fa fa-check-circle'
				},
				failure : {
					classname : 'fd fa-warning'
				}
			};

		cancel_button.on('click', function () {
			form.trigger('reset');
			file_field.trigger('change');
		});

    //selecting a file to upload to trim
		file_field.on('change', function () {
			var chosen = file_field.val();
			if(chosen) {
				choose_button.hide();
				message_icon[0].className = status_messages.selected.classname;
				upload_message.text(status_messages.selected.message);
				message_container.show();
				actions.show();
			} else {
				choose_button.show();
				actions.hide();
				message_container.hide();
			}
		});
    //clicking on the "choose trim file" button
		choose_button.on('click', function () {
			file_field.click();
		});

		form // clicking on open trim link to open an uploaded file
			.on('ajax:error', function(e, response) {
				var json = JSON.parse(response.responseText);

				message_icon.addClass(status_messages[json.status].classname);
				upload_message.text(json.message);

				actions
					.hide()
					.after('<a href="'+ json.link +'" rel="external">Open trim link</a>');
				message_container.show();
			})
			.on('ajax:success', function(e, response) {
				var json = JSON.parse(response.responseText),
					success = json.status === 'success';

				message_icon.addClass(status_messages[json.status].classname);
				upload_message.text(json.message);

				if(success) {
					actions
						.hide()
						.after('<a href="'+ json.link +'" rel="external">Open trim link</a>');
				}
				message_container.show();
      });

    });
};

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

  $('.datetimepicker').datetimepicker();
  $('.dateonlypicker').datetimepicker({ pickTime: false });
  $('.minister-select').ministerSelect({inputClass: 'minister-select-input form-control'});
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
      var uin = $('#pq-frame-'+pqid+ ' h3').text();
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

    $('.date-for-answer-picker').datetimepicker({pickTime: false});

    $('.internal-deadline-picker').each(function() {
      var empty = ($(this).find('input').val() === '');
      $(this).data('empty', empty);
    }).datetimepicker().on("dp.show",function () {
      var picker = $(this).data('DateTimePicker'),
        empty = $(this).data('empty') || false,
        date;

      if (empty === true) {
        date = picker.getDate();
        date.hour(10);
        date.minute(0);
        picker.setDate(date);
      }

      $(this).removeData('empty');
    }).on('change', function() {
      $(this).removeData('empty');
    });

    $('.ao-reminder-link').on('ajax:success', function(e, data){
      $(this).after(data);
    });

	if($('.trim_area').length){
		trimFileUpload();
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



