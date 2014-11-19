toggleCancelLink = function showCancelLink () {
  var cancel = $('#progress-menu-trim-data .cancel'),
      field = $('#pq_trim_link_attributes_file');

  if (field.val() && field.val() !== '') {
    cancel.show();
  } else {
    cancel.hide();
  }
};

cancelFileSelection = function cancelFileSelection (e) {
  e.preventDefault();
  $('#pq_trim_link_attributes_file').replaceWith('<input id="pq_trim_link_attributes_file" name="pq[pq_trim_link_attributes][file]" type="file">');
  toggleCancelLink();
};

$('#pq_trim_link_attributes_file').on('change', toggleCancelLink);
$('#progress-menu-trim-data .cancel').on('click', cancelFileSelection);
