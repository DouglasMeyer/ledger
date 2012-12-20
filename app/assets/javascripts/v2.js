//= require jquery
//= require_tree ./v2/

var currency = {
  parse: function(input){
    return Math.round(input * 100) / 100;
  },
  format: function(input, options){
    options = jQuery.extend({ symbol: true }, options);
    var parts = ('' + currency.parse(input)).match(/(-)?(\d+)(?:\.(\d+))?/),
        dollars = parts[2].replace(/(\d)(?=(\d{3})+$)/g, '$1,'),
        cents = ((parts[3] || '') + '00').substr(0,2);
    return (parts[1] || '') +
           (options.symbol ? "$" : "") +
           dollars+"."+cents;
  }
};

jQuery.fn.extend({

  currency: function(value){
    var elem = $(this[0]),
        isInput = jQuery.nodeName(this[0], 'input');
    if (value !== undefined) {
      elem.toggleClass('negative', value < 0);
      if (isInput) {
        elem.val(currency.format(value, { symbol: false }));
      } else {
        elem.text(currency.format(value));
      }
    }
    return currency.parse(isInput ? elem.val() : elem.text());
  }

});

jQuery(function($){

  $('form input:visible, form select:visible').first().focus().select();

});
