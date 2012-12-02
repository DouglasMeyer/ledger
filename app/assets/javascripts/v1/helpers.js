var centsToCurrency = function(cents){
  var string = (cents + '').split(''),
      cents = [],
      negative = string[0] === '-';
  if (negative) { string.shift(); }
  cents.unshift(string.pop() || '0');
  cents.unshift(string.pop() || '0');
  return (negative ? '-' : '') + (string.join('') || '0') + '.' + cents.join('');
};

var currencyToCents = function(currency){
  return currency ? Math.round(parseFloat(currency) * 100) : 0;
};
