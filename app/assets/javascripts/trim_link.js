// The functions in this file manages all the behaviour uploads / cancels to trim.
// in both the new and in progress tables on the dashboard
'use strict';

var trimLink = {};

// Maximum authorised size of files to upload (in bytes)
trimLink.maxFileSize = 50000;

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
    var $uploadMessage;
    var fileSize;

    // check if a file was selected successfully
    // and is under the maximum file size
    if (selectedPath) {
      fileSize = $fileField.prop('files')[0].size;
      $uploadMessage = $('#tr5-message');
      selectedFileName = selectedPath.split(/[\\/]/).pop();
      $('#choices').hide();

      if (fileSize > trimLink.maxFileSize) {
        $('.fa-file-o').toggleClass('fa-warning');
        $uploadMessage.text('This file is too large: ' + selectedFileName);
      } else {
        $uploadMessage.text('File selected: ' + selectedFileName);
      }
      $('#status').show();
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
      },
      filesize : {
        message : 'This file is too large',
        classname : 'fa fa-warning'
      }
    };

    // called when a file has been chosen by the user
    function fileSelectedCallback() {
      var chosen = $fileField.val();
      var selectedFileName;
      var filesize = $fileField.prop('files')[0].size;
      var statusMessage;

      if(chosen) {
        // If a file is selected successfully, show a message
        selectedFileName = chosen.split(/[\\/]/).pop();
        $chooseButton.hide();

        if(filesize > trimLink.maxFileSize) {
          statusMessage = statusMessages.filesize;
          $actions.find('.button-upload').hide();
        } else {
          statusMessage = statusMessages.selected;
          $actions.find('.button-upload').show();
        }

        $messageIcon[0].className = statusMessage.classname;
        $uploadMessage.text(statusMessage.message +': '+selectedFileName);
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

    // clicking on the "upload" button
    $(".button-upload").on('click', function(event) {
      var formData = new FormData($form[0]);
      $.ajax({
        type: 'post',
        url: '/trim_links',
        data: formData,
        contentType: false,
        processData: false,
        cache: false
      })
      .done(function (data) {
        if (data.status === 200) {
          $messageIcon.attr('class', statusMessages.success.classname);
          $actions
            .hide()
            .after('<a href="'+ data.link +'" rel="external">Open trim link</a>');
        } else {
          $messageIcon.attr('class', statusMessages.failure.classname);
          $actions.find('.button-upload').hide();
        }
        $uploadMessage.text(data.message);
      })
      .fail(function() {
        $messageIcon.attr('class', statusMessages.failure.classname);
        $uploadMessage.text("Server error. Please try again or contact support.");
      })
      .always(function() {
        $messageContainer.show();
      });
    });
  });
}
