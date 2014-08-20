//= require ../bower_components/angular/angular
//= require ../bower_components/angular-animate/angular-animate

angular.module('ledger', ['ng', 'ngAnimate'])

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
        element.toggleClass 's-negative', (value < 0)

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


  .directive 'EntryItem', ($timeout, Model, $parse)->
    restrict: 'C'
    link: (scope, element, attrs) ->
      watchAEs = undefined
      amountRemainingCentsExpression = 'entry.amountCents - (entry.accountEntries | sum:"amountCents")'

      reset = ->
        scope.isOpen = false
        delete scope.stashedEntry
        scope.form.$setPristine()

        scope.amountCents = scope.entry.amountCents
        scope.type = if !scope.entry.id
          'New'
        else if scope.amountCents == 0
          'Transfered'
        else if scope.amountCents > 0
          #FIXME: I'm not sure I like how this sounds: Recieved $5.00 to Doug Blow
          scope.amountCents = 0
          'Recieved'
        else
          'Spent'

        scope.from = for ae in scope.entry.accountEntries when ae.amountCents < 0
          ae.accountName
        scope.to = for ae in scope.entry.accountEntries when ae.amountCents > 0
          scope.amountCents += ae.amountCents
          ae.accountName

        scope.open() unless scope.entry.id

      selectAE = (accountEntry)->
        $timeout ->
          index = scope.entry.accountEntries.indexOf(accountEntry)
          input = element[0].querySelector(".table__row:nth-child(#{index+2})").querySelector('input, select')
          input.select() if input

      scope.open = ->
        return if scope.isOpen
        scope.isOpen = true
        scope.stashedEntry = angular.copy(scope.entry)
        watchAEs = scope.$watch amountRemainingCentsExpression, (amountRemainingCents)->
          if amountRemainingCents
            if !scope.form.amount? || scope.form.amount.$dirty || scope.form.account.$modelValue
              newAE = amountCents: amountRemainingCents
              scope.entry.accountEntries.push( newAE )
              selectAE(newAE) if scope.entry.accountEntries.length == 1
            else
              lastAE = scope.entry.accountEntries[scope.entry.accountEntries.length-1]
              lastAE.amountCents += amountRemainingCents
        selectAE(scope.entry.accountEntries[0]) if scope.entry.accountEntries[0]

      scope.close = (e)->
        e.stopPropagation()
        watchAEs()
        if scope.entry.id
          scope.entry = scope.stashedEntry
          reset()
        else
          index = scope.entries.indexOf(scope.entry)
          scope.entries.splice(index, 1)

      scope.save = (e)->
        e.stopPropagation()
        scope.entry.accountEntries.forEach (ae)->
          ae._destroy = true unless ae.amountCents
        scope.entry.accountEntries = scope.entry.accountEntries.filter (ae)->
          ae.id || (ae.amountCents && ae.accountName)
        Model.BankEntry.save(scope.entry).then (bankEntries)->
          scope.entry = bankEntries[0]
        reset()

      reset()
      scope.open() if $parse(amountRemainingCentsExpression)(scope)

  .factory 'Model', ($http, $filter, $window)->
    strUnderscore = $filter('underscore')
    underscore = (cObj)->
      return cObj unless angular.isObject(cObj)

      uObj = {}
      for name, val of cObj when name.charAt(0) != '$' && name != 'className'
        newName = strUnderscore(name)
        if angular.isArray(val)
          uObj[newName] = ( underscore(v) for v in val )
        else if angular.isObject(val)
          uObj[newName] = underscore(val)
        else
          uObj[newName] = val
      uObj

    camelize = (uObj)->
      return uObj unless angular.isObject(uObj)

      cObj = {}
      for name, val of uObj
        newName = name.replace /_(\w)/g, (_,l)-> l.toUpperCase()
        if angular.isArray(val)
          cObj[newName] = ( camelize(v) for v in val )
        else if angular.isObject(val)
          cObj[newName] = camelize(val)
        else
          cObj[newName] = val
      cObj

    Model =
      get: (id)->
        @_all ||= {}
        @_all[id] ||= {}

      load: (datas)->
        for data in datas
          record = @get(data.id)
          record[k] = v for k, v of camelize(data)
          record

      handleResponse: (response)->
        for type, recordsById of response.data.records
          models[type].load(data for id, data of recordsById)
        for reference in response.data.responses[0].records
          models[reference.type].get(reference.id)

      read: (opts={})->
        opts.resource = @resource
        opts.action = 'read'
        $http
          .post('/api', JSON.stringify([ opts ]) )
          .then(@handleResponse)

      save: (attrs, opts={})->
        opts.resource = @resource
        opts.action = if attrs.id? then 'update' else 'create'
        opts.id = attrs.id
        opts.data = attrs
        $http
          .post('/api', JSON.stringify([ opts ]) )
          .then(@handleResponse)

    Object.defineProperty Model, 'all',
      get: ->
        return @_getAll if @_getAll?
        @read().then (all)=>
          $window.localStorage.setItem("Model.#{@name}.all", angular.toJson(all))
          @_getAll.splice(0,@_getAll.length, all...)
        try
          @_getAll = @load(angular.fromJson($window.localStorage.getItem("Model.#{@name}.all")))
        @_getAll ||= (record for id, record of @_all)
      enumerable: true
      configurable: false

    models =
      Account: Object.create Model,
        name: value: 'Account'
        resource: value: 'Account_v1'

      BankEntry: Object.create Model,
        name: value: 'BankEntry'
        resource: value: 'BankEntry_v1'

        save: value: (camelcaseAttrs, opts={})->
          attrs = underscore(camelcaseAttrs)
          delete attrs.balance_cents
          attrs.account_entries_attributes = attrs.account_entries
          delete attrs.account_entries

          Model.save.call(this, attrs, opts)

      AccountEntry: Object.create Model,
        name: value: 'AccountEntry'

  .controller 'EntriesCtrl', ($scope, Model, $window)->
    bankEntryOffset = 0

    $scope.loadMore = ->
      $scope.isLoadingEntries = true
      promise = Model.BankEntry.read(limit: 30, offset: bankEntryOffset).then (entries)->
        newEntries = entries.filter (entry)-> entry not in $scope.entries
        if $scope.entriesFromLocalStorage
          $scope.entries.splice(0, 0, newEntries...)
        else
          $scope.entries.splice($scope.entries.length, 0, newEntries...)
        delete $scope.isLoadingEntries
        entries
      bankEntryOffset += 30
      promise

    try
      $scope.entries = Model.BankEntry.load(angular.fromJson($window.localStorage.getItem('EntriesCtrl.entries')))
      $scope.entriesFromLocalStorage = true
    $scope.entries ||= []
    $scope.loadMore().then (entries)->
      $window.localStorage.setItem('EntriesCtrl.entries', angular.toJson(entries))
      oldEntries = $scope.entries.filter (entry)-> entry not in entries
      for entry in oldEntries
        index = $scope.entries.indexOf(entry)
        $scope.entries.splice(index, 1)
      delete $scope.entriesFromLocalStorage
    $scope.accounts = Model.Account.all

    $scope.$on 'addEntry', ->
      today = (new Date).toJSON().slice(0,10)
      $scope.entries.unshift({ date: today, accountEntries: [{}] })

  .controller 'AccountsCtrl', ($scope, Model)->
    $scope.accounts = Model.Account.all
    $scope.$watchCollection 'accounts | orderBy:"position"', (accounts)->
      $scope.assetCategories = []
      $scope.liabilityCategories = []
      for account in accounts
        category = account.category
        categories = if account.asset then $scope.assetCategories else $scope.liabilityCategories
        categories.push(category) unless category in categories

  .controller 'CalculatorCtrl', ($scope, Model, $filter, $parse)->
    underscore = $filter('underscore')

    calcScope = {}
    $scope.accounts = Model.Account.all
    $scope.$watchCollection 'accounts', (all)->
      calcScope = {}
      return unless all
      calcScope[underscore(account.name)] = account.balanceCents / 100 for account in all

    $scope.toggle = ->
      $scope.showCalc = !$scope.showCalc
      $scope.input = ''

    $scope.$watch 'input', (input)->
      try
        $scope.output = if input
          $parse(input)(calcScope) * 100
        else
          ''
        $scope.form.input.$setValidity('parses', true)
      catch
        $scope.form.input.$setValidity('parses', false)
