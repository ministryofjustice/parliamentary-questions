//= require jquery.autocomplete
var jQuery;
(function ($) {
  'use strict';

  $.fn.ministerSelect = function (options) {
    var settings = $.extend({
      inputClass: 'minister-select-input'
    }, options);

    return this.each(function () {
      var $select = $(this),
        $input = $('<input type="text" value="" class="' + settings.inputClass + '" />'),
        lookup = [];

      // compile the list of auto suggestions from the select and pre-fill the input field
      $select.find('option').each(function () {
        var $option = $(this);

        lookup.push($option.text());
        if ($option.is(':selected')) {
          $input.val($option.text());
        }
      });

      // construct the auto complete and only trigger change method on the input when user selects an option
      $input.autocomplete({
        lookup: lookup,
        onSelect: function () {
          $(this).trigger('change');
        }
      });

      // when the input changes, the relevant select option has to be chosen
      $input.on('change', function () {
        var textToCompare = $(this).val().toLowerCase(),
        matching_options = $.grep(lookup, function(suggestion) {
          return suggestion.toLowerCase().indexOf(textToCompare) !== -1;
        });

        if (matching_options.length === 1) {
          var $option = $select.find('option:contains("' + matching_options[0] + '")').first();

          $select.val($option.val());
          $input.val($option.text());
        } else {
          $select.val('');
          $input.val('');
        }
      });

      if ( $select && $select.attr('disabled') ) { $input.attr('disabled', true); }
        $select.hide();
        $select.before($input);
    });
  };
}(jQuery));
