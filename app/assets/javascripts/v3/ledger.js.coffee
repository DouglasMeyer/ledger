//= require ../bower_components/angular/angular
//= require ../bower_components/angular-animate/angular-animate

angular.module('ledger', ['ng', 'ngAnimate'])

  .run ($rootScope, $window, $q)->
    deferred = undefined
    $window.applicationCache.addEventListener('downloading', (event)->
      deferred = $q.defer()
      $rootScope.$apply ->
        $rootScope.$emit 'status',
          text: 'updating'
          promise: deferred.promise
    , false)
    $window.applicationCache.addEventListener('error', (event)->
      $rootScope.$apply ->
        deferred?.reject('error')
    , false)
    $window.applicationCache.addEventListener('updateready', (event)->
      $rootScope.$apply ->
        deferred.resolve('updateready')
        $rootScope.$emit 'status',
          text: 'Refresh for update'
          fn: -> $window.location.reload()
    , false)


  .filter 'join', ->
    (input)-> input?.join(', ')

  .filter 'sum', ->
    (input, prop)->
      input = input?.map((e)-> parseInt(e[prop]) || 0) if prop
      input?.reduce ((a, b)-> a+b), 0

  .filter 'underscore', ->
    (input)->
      input.replace(/([a-z])([A-Z])/g, (_,a,b)-> "#{a}_#{b}").replace(/\W+/g, '_').toLowerCase()

  .directive 'lCurrency', ($filter)->
    numberFilter = $filter('number')

    restrict: 'A'
    require: 'ngModel'
    link: (scope, element, attrs, ngModel) ->
      return unless ngModel

      updateClass = (value) ->
        element.toggleClass 'is-negative', (value < 0)

      formatter = (value) ->
        updateClass value
        if value
          value = '$' + numberFilter(value/100, 2)
        value

      parser = (value, strict=false) ->
        if strict || value.match /^\$?-?[\d,]*(.\d*)?$/
          value = parseFloat(value.replace(/[^\d.-]/g, ''), 10) || null
          value *= 100 if value
        updateClass value
        value

      ngModel.$parsers.push parser
      ngModel.$formatters.push formatter

      $(element).blur ->
        value = parser element.val(), true
        value = formatter value if value
        element.val value

      if !$(element).is('input')
        ngModel.$render = ->
          value = ngModel.$viewValue
          if typeof value == 'number' || typeof value == 'string'
            element.text ngModel.$viewValue
          else
            element.text ''

  .directive 'lSelect', ($timeout)->
    selectTimeout = undefined
    selectElement = (element, selector)->
      element = element.querySelector(selector) if selector
      element?.select()

    restrict: 'A'
    link: (scope, element, attrs)->
      scope.$watch attrs.lSelect, (value)->
        if value
          $timeout.cancel(selectTimeout) if selectTimeout
          selectTimeout = $timeout ->
            selectElement(element[0], attrs.lSelectSelector)
