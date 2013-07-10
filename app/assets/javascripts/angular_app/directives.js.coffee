angular.module('Ledger').directive 'lCurrency', [ '$filter', ($filter) ->
  numberFilter = $filter('number')

  require: '?ngModel'
  link: (scope, element, attrs, ngModel) ->
    element.addClass 'currency'
    return unless ngModel

    updateClass = (value) ->
      element.toggleClass 'negative', (value < 0)

    formatter = (value) ->
      updateClass value
      if value
        value = '$' + numberFilter(value/100, 2)
      value

    parser = (value, strict=false) ->
      if strict || value.match /^\$?-?\d[\d,.]*$/
        value = parseFloat(value.replace(/[^\d.-]/g, ''), 10) || null
      updateClass value
      value

    ngModel.$parsers.push parser
    ngModel.$formatters.push formatter

    $(element).blur ->
      value = parser element.val(), true
      value = formatter value*100 if value
      element.val value

    if !$(element).is('input')
      ngModel.$render = ->
        value = ngModel.$viewValue
        if typeof value == 'number' || typeof value == 'string'
          element.text ngModel.$viewValue
        else
          element.text ''
]
