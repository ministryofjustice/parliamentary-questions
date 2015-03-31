// The functions in this file manages all the behaviour uploads / cancels to trim.
// in both the new and in progress tables on the dashboard


var trim_link = {};

// Prepare the callback on trim upload controls
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
      cancel_button = container.find('.button-cancel'),
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
          classname : 'fa fa-warning'
        }
      };

    cancel_button.on('click', function () {
      form.trigger('reset');
      choose_button.show();
      actions.hide();
      message_container.hide();
    });


    // called when a file has been chosen by the user
    function file_selected_callback() {
      var chosen = file_field.val();
      if(chosen) {
        // If a file is selected successfully, show a message
        choose_button.hide();
        message_icon[0].className = status_messages.selected.classname;
        upload_message.text(status_messages.selected.message);
        message_container.show();
        actions.show();
      } else {
        // or else, go back to showing just the 'Choose Trim link' button
        choose_button.show();
        actions.hide();
        message_container.hide();
      }
    }

    // File selector behaviour
    file_field.on('change', file_selected_callback);

    //clicking on the "choose trim file" button
    choose_button.on('click', function () {
      file_field.click();
    });

    // trim file async upload callbacks
    form
      .on('ajax:error', function(e, response) {
        var json = JSON.parse(response.responseText);

        if (json.status === 200) {
          message_icon.attr('class', status_messages.success.classname);
          actions
            .hide()
            .after('<a href="'+ json.link +'" rel="external">Open trim link</a>');
        } else {
          message_icon.attr('class', status_messages.failure.classname);
        }
        upload_message.text(json.message);
        message_container.show();

        // iframe-transport removes the change event handler when uploading,
        // so we need to add it back
        file_field = form.find('.trim-file-chooser');
        file_field.on('change', file_selected_callback);
      })
      .on('ajax:success', function(e, response) {
        // trim file upload with iframe-transport always returns error
      });

    });
};



// Trim link behaviour on PQ details page

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
