var PQ = PQ || {};

PQ.trimFileUpload = function() {
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

		cancel_button.on('click', function (e) {
			form.trigger('reset');
			file_field.trigger('change');
		});

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

		choose_button.on('click', function () {
			file_field.click();
		})

		form
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
				} else {

				}

				message_container.show();
			});

 	});
}
PQ.toggleSiblingContent = function(){
	$('details').each(function(i, el){
		var root = $(el),
			summary = root.find('span.link'),
			content = root.find('.reveal');

		summary.on('click', function(){
			content.toggleClass('closed');
			summary.toggleClass('opened');
		});
	});
}

$(document).ready(function () {
	$('.datetimepicker').datetimepicker();

    $('.dateonlypicker').datetimepicker({
        pickTime: false
    });

	$(".multi-select-action-officers").select2({width:'250px'});

    $(".single-select-dropdown").select2({width:'250px', allowClear: true});

    $('#allocation_response_response_action_accept').click(function (){
		$('#reason-textarea').addClass('hide');
	});

	$('#allocation_response_response_action_reject').click(function (){
		$('#reason-textarea').removeClass('hide');
	});

	$(".form-commission")
		.on("ajax:success", function(e, data){
			var pqid = $(this).data('pqid');
	        var uin = $('#pq-frame-'+pqid+ ' h3').text();
	        //it worked!
	        //so - get the entire question and replace it with a flash success message
	        $('#pq-frame-'+pqid).replaceWith('<div class="alert alert-success fade in"><button class="close" data-dismiss="alert">×</button>'+ uin +' commissioned successfully</div>');
	        //increment allocated pending
	        incrementBadge('#db-filter-alloc-pend');
	        //decrement Unallocated
	        decrementBadge('#db-filter-unalloc');

		}).on("ajax:error", function(e, xhr) {
			console.log(xhr.responseText);
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

    $('.internal-dtp').datetimepicker().on('change', function() {
        $(this).siblings('input[type="submit"]').val("Update").show();
    });

    $('.internal-deadline-form')
        .on("ajax:success", function(){
            var pqid = $(this).data('pqid');
            //get the div to refresh
            var divToUpdate = "btn-set-deadline-" + pqid;
            //put the dat returned into the div
            $('#'+divToUpdate).val("Updated").fadeOut(1000);

        }).on("ajax:error", function(e, xhr, status, error) {
            console.log(error);
            //TODO how should ux handle error? Add it to the list, alert, flash, etc...
        });


    $('.date-for-answer-form')
        .on("ajax:success", function(){
            var pqid = $(this).data('pqid');
            //get the div to refresh
            var divToUpdate = "btn-set-date-for-answer-" + pqid;
            //put the dat returned into the div
            $('#'+divToUpdate).val("Updated").fadeOut(1000);

        }).on("ajax:error", function(e, xhr, status, error) {
            console.log(error);
            //TODO how should ux handle error? Add it to the list, alert, flash, etc...
        });

    $('.delete-trim-form')
        .on("ajax:success", function(){
            var trimid = $(this).data('trimid');
            //get the div to refresh
            var divToUpdate = "trim_links_" + trimid;
            //put the dat returned into the div
            $('#'+divToUpdate).val("Updated").fadeOut(1000);

        }).on("ajax:error", function(e, xhr, status, error) {
            console.log(error);
            //TODO how should ux handle error? Add it to the list, alert, flash, etc...
        });

    $('.ao-reminder-link').on('ajax:success', function(e, data){
        $(this).after(data);
    });

	if($('.trim_area').length){
		PQ.trimFileUpload();
	}
	if($('details').length){
		PQ.toggleSiblingContent();
	}

	$('.comm-header').on('click', function () {
      var pqid = $(this).data('pqid');
      var $caret = $(this).children('#comm-caret-' + pqid);
      $caret.toggleClass('fa-caret-right').toggleClass('fa-caret-down');
      $('#comm-details-' + pqid).toggleClass('start-hidden');
  });

  $('.progress-menu-item').on('click',function() {
      //hide all progress-menu-data items
      $('.progress-menu-data').hide();
      //and show the required
      $('#' + $(this).attr('id') + '-data').show();
      $('.progress-menu-form').show();
  });

  /* PQ Details Page - Set intial opened tab */
  var pqStage = $("#pq_progress_id option:selected").val();
  if(pqStage === 2 || pqStage === 4) {
      $("#progress-menu-com").addClass("activeTab");
      $("#progress-menu-com-data").removeClass("start-hidden");
  }
  else if (pqStage === 3 || pqStage === 6) {
      $("#progress-menu-sub").addClass("activeTab");
      $("#progress-menu-sub-data").removeClass("start-hidden");
  }
  else if (pqStage === 7 || pqStage === 8 || pqStage === 9) {
      $("#progress-menu-pod").addClass("activeTab");
      $("#progress-menu-pod-data").removeClass("start-hidden");
  }
  else if (pqStage === 10 || pqStage === 11 || pqStage === 12) {
      $("#progress-menu-min").addClass("activeTab");
      $("#progress-menu-min-data").removeClass("start-hidden");
  }
  else if (pqStage === 13 || pqStage === 14) {
      $("#progress-menu-answer").addClass("activeTab");
      $("#progress-menu-answer-data").removeClass("start-hidden");
  }
  else {
      $("#progress-menu-pq").addClass("activeTab");
      $("#progress-menu-pq-data").removeClass("start-hidden");
  }

  /* PQ Details Page - Set styling when tab clicked */
  $("a").click(function() {
      var e="#"+$(this).attr("id");
      $("#progress-menu-pq, #progress-menu-fc, #progress-menu-com, #progress-menu-sub, #progress-menu-pod, #progress-menu-min, #progress-menu-answer").removeClass( "activeTab" ).addClass("inactiveTab");
      switch(e){
          case "#progress-menu-pq":
              $(e).removeClass("inactiveTab").addClass("activeTab");
          break;
          case "#progress-menu-fc":
              $(e).removeClass("inactiveTab").addClass("activeTab");
          break;
          case "#progress-menu-com":
              $(e).removeClass("inactiveTab").addClass("activeTab");
          break;
          case "#progress-menu-sub":
             $(e).removeClass("inactiveTab").addClass("activeTab");
          break;
          case "#progress-menu-pod":
              $(e).removeClass("inactiveTab").addClass("activeTab");
          break;
          case "#progress-menu-min":
              $(e).removeClass("inactiveTab").addClass("activeTab");
          break;
          case "#progress-menu-answer":
              $(e).removeClass("inactiveTab").addClass("activeTab");
          break;
      }
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

function incrementBadge(id_of_navpill) {
    changeBadgeBy(id_of_navpill,1);
}
function decrementBadge(id_of_navpill) {
    changeBadgeBy(id_of_navpill,-1);
}
function changeBadgeBy(id_of_navpill, val) {
    var $badge = $(id_of_navpill).children('a').children('span');
    var curval = parseInt($badge.text(),10);
    var nextval = curval+val;
    if (nextval < 0) {
        nextval = 0;
    }
    $badge.text(nextval);
}
