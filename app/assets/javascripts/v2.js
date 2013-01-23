//= require jquery
//= require_self
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
      return this;
    } else {
      return currency.parse(isInput ? elem.val() : elem.text());
    }
  }

});

//NOTE: this may be a bit of over-kill, but it works.
Function.prototype.delay = function(time, keyFunc){
  var func = this,
      timers = {},
      keyFunc = keyFunc || function(that, args){ return args[0].id; };
  return function(){
    var that = this,
        args = arguments,
        key = keyFunc(this, arguments),
        timer = timers[key];
    if (timer) clearTimeout(timer);
    timers[key] = setTimeout(function(){
      func.apply(that, args);
      timers[key] = undefined;
    }, time);
  };
};

jQuery(function($){

  $('form input:visible, form select:visible').first().focus().select();

});
