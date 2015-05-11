// The functions in this file manages all the behaviour uploads / cancels to trim.
// in both the new and in progress tables on the dashboard
'use strict';

var trimLink = {};



trimLink.setUpTrimControls = function() {
  var $fileField, $status, $choices;

  // check if we're on the details page
  if (document.getElementById('pq-details')) {
    trimLink.setUpDetailsPage();
  }

  // check if we're on the dashboard
  if (document.getElementById('dashboard')) {
    trimLink.setUpDashBoard();
  }
};


/*
 * sets up trim file upload controls on a PQ details page
 */
trimLink.setUpDetailsPage = function() {
  var $fileField = $('input[type=file]');
  var $status = $('#status');
  var $choices = $('#choices');

  $status.hide();

  $choices.on('click', function () {
    $('#pq_trim_link_attributes_file').click();
  });

  $('#cancel').on('click', function () {
    $('form.progress-menu-form').trigger('reset');
    $status.hide();
    $choices.show();
  });

  $fileField.on('change', function(){
    var selectedPath = $fileField.val();
    var selectedFileName;
    var $messageContainer = $('#status');
    var $uploadMessage = $('#tr5-message');
    var $chooseBtn = $('#choices');
    if(selectedPath) {

      // If a file is selected successfully, show a message
      selectedFileName = selectedPath.split(/[\\/]/).pop();
      $chooseBtn.hide();
      $uploadMessage.text('File selected: ' + selectedFileName);
      $messageContainer.show();
    }
  });
}


/*
 * sets up trim file upload controls on the dashboard
 */
trimLink.setUpDashBoard = function() {

  // loop through all the trimlink upload controls visible on the dashboard
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
        classname : 'fa fa-file-o'
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

    // called when a file has been chosen by the user
    function fileSelectedCallback() {
      var chosen = $fileField.val();
      var selectedFileName;
      if(chosen) {
        // If a file is selected successfully, show a message
        selectedFileName = chosen.split(/[\\/]/).pop();
        $chooseButton.hide();
        $messageIcon[0].className = statusMessages.selected.classname;
        $uploadMessage.text(statusMessages.selected.message +': '+selectedFileName);
        $messageContainer.show();
        $actions.show();
      }
    }

    $cancelButton.on('click', function () {
      $form.trigger('reset');
      $chooseButton.show();
      $actions.hide();
      $messageContainer.hide();
      $actions.find('.button-upload').show();
    });

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
          $actions.find('.button-upload').hide();
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
}
