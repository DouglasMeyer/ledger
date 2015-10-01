//= require angular/angular
//= require angular-animate/angular-animate
//= require angular-route/angular-route
//= require angular-rails-templates
//= require rrule/lib/rrule
//= require_tree ./templates

angular.module('ledger', ['ng', 'ngRoute', 'ngAnimate', 'templates'])

  .config ($routeProvider, $provide)->

    # TrackJs exception handling
    $provide.decorator '$exceptionHandler', ($delegate, $window)->
      (exception, cause)->
        if $window.trackJs
          $window.trackJs.track(exception)
        $delegate(exception, cause)

    # routes
    $routeProvider
      .when('/accounts',
        templateUrl: 'v3/templates/accounts.html'
        resolve:
          data: (dataRefresh)-> dataRefresh()
      )
      .when('/accounts/edit',
        templateUrl: 'v3/templates/accounts_edit.html'
        resolve:
          data: (dataRefresh)-> dataRefresh()
      )
      .when('/entries',
        templateUrl: 'v3/templates/entries.html'
        resolve:
          data: (dataRefresh)-> dataRefresh()
      )
      .when('/forecast',
        templateUrl: 'v3/templates/forecast.html'
        resolve:
          data: (dataRefresh)-> dataRefresh()
      )
      .otherwise redirectTo: '/accounts'

  .factory 'dataRefresh', (Model, $window, $rootScope, $q, entriesNeedingDistribution, ledgerSummary)->
    cachedModels = {}
    storage = $window.localStorage

    refresh = (name)->
      unless Model[name].all.length
        try
          cachedModels[name] = Model[name].load(angular.fromJson(storage.getItem("Model.#{name}.all")))
          Model[name].all.isFromLocalStorage = true
      Model[name].promise = Model[name].read()
      Model[name].promise.then (all)->
        delete Model[name].promise
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
      promises.push(refresh('ProjectedEntry'))
      promises.push(Model.BankEntry.read(needsDistribution: true).then (entries)->
        oldLength = entriesNeedingDistribution.length
        args = [0,oldLength].concat(entries)
        entriesNeedingDistribution.splice.apply(entriesNeedingDistribution, args)
      )
      promises.push(Model.LedgerSummary.read().then (summary)->
        angular.copy summary, ledgerSummary
      )

      $rootScope.$emit 'status',
        text: 'loading'
        promise: $q.all(promises)

      undefined

  .value 'entriesNeedingDistribution', []

  .value 'ledgerSummary', {}

  .run ($rootScope, $window, $q, appCache, $http)->

    # So rails knows we are doing XHR requests.
    $http.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest";

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


  .filter 'unique', ->
    (list)->
      list.reduce( (p, c)->
        if p.indexOf(c) < 0
          p.push(c)
        p
      , [])

  .filter 'join', ->
    (input)-> input?.join(', ')

  .filter 'pMap', ->
    (input, prop)->
      input?.map((e)-> e[prop])

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

  .directive 'lDraggable', ($parse)->
    restrict: 'A'
    link: (scope, element, attrs)->
      if attrs.lDraggableHandle
        element.on 'mouseover', attrs.lDraggableHandle, (event)->
          element.attr('draggable', 'true')

        element.on 'mouseout', attrs.lDraggableHandle, (event)->
          element.attr('draggable', 'false')
      else
        element.attr('draggable', 'true')

      if dragStart = $parse attrs.lDraggable
        element.on 'dragstart', (e)->
          scope.$apply -> dragStart(scope, { $event: e })

      if dragEnd = $parse attrs.lDraggableEnd
        element.on 'dragend', (e)->
          scope.$apply -> dragEnd(scope, { $event: e })

  .directive 'lDroppable', ($parse)->
    restrict: 'A'
    link: (scope, element, attrs)->

      if dragover = $parse(attrs.lDroppableOver)
        element.on 'dragover', (e)->
          scope.$apply -> dragover(scope, { $event: e })

      if attrs.lDroppable
        drop = $parse(attrs.lDroppable)
        element.on 'drop', (e)->
          scope.$apply -> drop(scope, { $event: e })
