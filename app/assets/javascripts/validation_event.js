(function () {
  window.onload = function() {
    window.dataLayer = window.dataLayer || [];

    if($('.pq-msg-warning, .pq-msg-error').size() > 0) {
      $('.pq-msg-warning, .pq-msg-error').each( function(_, obj) {
        window.dataLayer.push({
          event: "validation_error",
          errorMessage: obj.textContent
        });
      });
    }
  }
}).call(this);
