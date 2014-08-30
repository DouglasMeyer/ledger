//= require ../bower_components/angular/angular
//= require ../bower_components/angular-animate/angular-animate
//= require ../bower_components/angular-route/angular-route
//= require angular-rails-templates
//= require_tree ./templates

angular.module('ledger', ['ng', 'ngRoute', 'ngAnimate', 'templates'])

  .config ($routeProvider)->
    $routeProvider
      .when('/accounts',
        templateUrl: 'v3/templates/accounts.html'
        controller: (dataRefresh)-> dataRefresh()
      )
      .when('/entries',
        templateUrl: 'v3/templates/entries.html'
        controller: (dataRefresh)-> dataRefresh()
      )
      .otherwise redirectTo: '/accounts'

  .factory 'dataRefresh', (Model, $window, $rootScope, $q)->
    cachedModels = {}
    storage = $window.localStorage

    refresh = (name)->
      unless Model[name].all.length
        try
          cachedModels[name] = Model[name].load(angular.fromJson(storage.getItem("Model.#{name}.all")))
          Model[name].all.isFromLocalStorage = true
      Model[name].read().then (all)->
        try
          storage.setItem("Model.#{name}.all", angular.toJson(all))
        delete Model[name].all.isFromLocalStorage
        if cachedModels[name]?
          for model in cachedModels[name]
            Model[name].unload(model) unless model in all
          delete cachedModels[name]

    ->
      promises = []
      promises.push(refresh('Account'))
      promises.push(refresh('BankEntry'))

      #Model.BankEntry.read(needsUpdate: true)
      #Model.BankImport.read(limit: 1)

      $rootScope.$emit 'status',
        text: 'loading'
        promise: $q.all(promises)

  .run ($rootScope, $window, $q, appCache)->
    deferred = undefined
    appCache
      .on 'downloading', ->
        deferred = $q.defer()
        $rootScope.$emit 'status',
          text: 'updating'
          promise: deferred.promise
      .on 'error', ->
        deferred?.reject('error')
      .on 'updateready', ->
        deferred.resolve('updateready')
        $rootScope.$emit 'status',
          text: 'Refresh for update'
          fn: -> $window.location.reload()


  .filter 'join', ->
    (input)-> input?.join(', ')

  .filter 'map', ->
    (input, prop)->
      input = input?.map((e)-> parseInt(e[prop]) || 0)

  .filter 'sum', ->
    (input)->
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
