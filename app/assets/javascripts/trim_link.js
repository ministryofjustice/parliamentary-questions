// The functions in this file manages all the behaviour uploads / cancels to trim.
// in both the new and in progress tables on the dashboard

var trimLink = {};

// Prepare the callback on trim upload controls
trimLink.trimFileUpload = function() {
  'use strict';
  $('.trim-links-form').each(function(i, area) {
    var $container = $(area);
    var $messageContainer = $container.find('.tr5-message');
    var $messageIcon = $messageContainer.find('.fa');
    var $uploadMessage = $messageIcon.siblings('.message');
    var $actions = $container.find('.tr5-actions');
    var $chooseButton = $container.find('.button-choose');
    var $form = $container.find('form');
    var $fileField = $form.find('.trim-file-chooser');
    var $cancelButton = $container.find('.button-cancel');
    var statusMessages = {
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

    $cancelButton.on('click', function () {
      $form.trigger('reset');
      $chooseButton.show();
      $actions.hide();
      $messageContainer.hide();
    });

    // called when a file has been chosen by the user
    function fileSelectedCallback() {
      var chosen = $fileField.val();
      if(chosen) {
        // If a file is selected successfully, show a message
        $chooseButton.hide();
        $messageIcon[0].className = statusMessages.selected.classname;
        $uploadMessage.text(statusMessages.selected.message);
        $messageContainer.show();
        $actions.show();
      } else {
        // or else, go back to showing just the 'Choose Trim link' button
        $chooseButton.show();
        $actions.hide();
        $messageContainer.hide();
      }
    }

    // File selector behaviour
    $fileField.on('change', fileSelectedCallback);

    //clicking on the "choose trim file" button
    $chooseButton.on('click', function () {
      $fileField.click();
    });

    // trim file async upload callbacks
    $form
      .on('ajax:error', function(e, response) {
        var json = JSON.parse(response.responseText);

        if (json.status === 200) {
          $messageIcon.attr('class', statusMessages.success.classname);
          $actions
            .hide()
            .after('<a href="'+ json.link +'" rel="external">Open trim link</a>');
        } else {
          $messageIcon.attr('class', statusMessages.failure.classname);
        }
        $uploadMessage.text(json.message);
        $messageContainer.show();

        // iframe-transport removes the change event handler when uploading,
        // so we need to add it back
        $fileField = $form.find('.trim-file-chooser');
        $fileField.on('change', fileSelectedCallback);
      })
      .on('ajax:success', function(e, response) {
        // trim file upload with iframe-transport always returns error
      });
  });
};

// Trim link behaviour on PQ details page
trimLink.toggleCancelLink = function() {
  'use strict';
  var $cancel = $('#progress-menu-trim-data .cancel');
  var $field = $('#pq_trim_link_attributes_file');

  if ($field.val() && $field.val() !== '') {
    $cancel.show();
  } else {
    $cancel.hide();
  }
};

trimLink.cancelFileSelection = function(e) {
  'use strict';
  e.preventDefault();
  $('#pq_trim_link_attributes_file').replaceWith('<input id="pq_trim_link_attributes_file" name="pq[pq_trim_link_attributes][file]" type="file">');
  trimLink.toggleCancelLink();
};

$('#pq_trim_link_attributes_file').on('change', trimLink.toggleCancelLink);
$('#progress-menu-trim-data .cancel').on('click', trimLink.cancelFileSelection);
