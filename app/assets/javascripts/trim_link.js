// The functions in this file manages all the behaviour uploads / cancels to trim.
// in both the new and in progress tables on the dashboard


var trim_link = {};

//function to upload file to trim
trim_link.trimFileUpload = function() {
  'use strict';
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

        message_icon.addClass(status_messages.failure.classname);
        upload_message.text(json.message);

        message_container.show();
      })
      .on('ajax:success', function(e, response) {
        var json = JSON.parse(response.responseText);

        message_icon.addClass(status_messages.success.classname);
        upload_message.text(json.message);

        actions
          .hide()
          .after('<a href="'+ json.link +'" rel="external">Open trim link</a>');

        message_container.show();
      });

    });
};

trim_link.toggleCancelLink = function() {
  'use strict';
  var cancel = $('#progress-menu-trim-data .cancel'),
      field = $('#pq_trim_link_attributes_file');

  if (field.val() && field.val() !== '') {
    cancel.show();
  } else {
    cancel.hide();
  }
};

trim_link.cancelFileSelection = function(e) {
  'use strict';
  e.preventDefault();
  $('#pq_trim_link_attributes_file').replaceWith('<input id="pq_trim_link_attributes_file" name="pq[pq_trim_link_attributes][file]" type="file">');
  trim_link.toggleCancelLink();
};

$('#pq_trim_link_attributes_file').on('change', trim_link.toggleCancelLink);
$('#progress-menu-trim-data .cancel').on('click', trim_link.cancelFileSelection);

