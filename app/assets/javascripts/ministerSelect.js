//= require jquery.autocomplete

(function ($) {
    $.fn.ministerSelect = function () {
        return this.each(function () {
            var dropdown = $(this);
            var input = $('<input type="text" value="" class="minister-select-input" />');
            var lookup = [];

            dropdown.find('option').each(function () {
                var option = $(this);

                lookup.push(option.text());
                if (option.is(':selected')) {
                    input.val(option.text());
                }
            });

            input.autocomplete({
                lookup: lookup,
                onSelect: function () {
                    $(this).trigger('change');
                }
            }).on('change', function () {
                var text = $(this).val();
                var options = dropdown.find('option').filter(function () {
                    return $(this).text().toLowerCase().indexOf(text.toLowerCase()) !== -1;
                });
                if (options.length == 1) {
                    var option = $(options[0]);

                    dropdown.val(option.val());
                    $(this).val(option.text());
                } else {
                    dropdown.val('');
                    $(this).val('');
                }
            });

            dropdown.hide();
            dropdown.before(input);
        });
    }
}(jQuery));