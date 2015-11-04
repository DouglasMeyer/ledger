//= require jquery
//= require ./v3/ledger
//= require_self
//= require_tree ./v3/

window.currency =
  parse: (input) ->
    Math.round(input * 100) / 100

  format: (input, options) ->
    options = jQuery.extend({ symbol: true }, options)
    parts = ('' + currency.parse(input)).match /// #(/(-)?(\d+)(?:\.(\d+))?/)
      (-)?          # Negative
      (\d+)         # Whole number
      (?:\.(\d+))?  # Decimal
    ///
    dollars = parts[2].replace(/(\d)(?=(\d{3})+$)/g, '$1,')
    cents = ((parts[3] || '') + '00').substr(0,2)

    return (parts[1] || '') +
           ( if options.symbol then "$" else "" ) +
           dollars+"."+cents

jQuery.fn.extend

  currency: (value) ->
    elem = $(this[0])
    isInput = jQuery.nodeName(this[0], 'input')
    if value != undefined
      elem.toggleClass('negative', value < 0)
      if isInput
        elem.val(currency.format(value, { symbol: false }))
      else
        elem.text(currency.format(value))
      return this
    else
      return currency.parse( if isInput then elem.val() else elem.text() )

jQuery.expr[':'].named = (elem, index, arg) ->
  jQuery(elem).is "[name$=\"[#{arg[3]}]\"]"

#NOTE: this may be a bit of over-kill, but it works.
Function::delay = (time, keyFunc) ->
  func = this
  timers = {}
  keyFunc = keyFunc || (that, args) -> args[0].id
  return ->
    that = this
    args = arguments
    key = keyFunc(this, arguments)
    timer = timers[key]
    clearTimeout(timer) if timer
    timers[key] = setTimeout( ->
      func.apply(that, args)
      timers[key] = undefined
    , time)


jQuery ($) ->

  $('form input:visible, form select:visible').first().focus().select()
