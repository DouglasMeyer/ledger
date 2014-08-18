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
          element[0].querySelector(".table__row:nth-child(#{index+2})").querySelector('input, select').select()

      scope.open = ->
        return if scope.isOpen
        scope.isOpen = true
        scope.stashedEntry = angular.copy(scope.entry)
        watchAEs = scope.$watch amountRemainingCentsExpression, (amountRemainingCents)->
          if amountRemainingCents
            if !scope.form.amount? || scope.form.amount.$dirty || scope.form.account.$dirty
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
        Model.bankEntry.save(scope.entry).then (bankEntries)->
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

    handleApiResponse = (response)->
      for type, recordsById of response.data.records
        for id, record of recordsById
          all[type][id] = camelize(record)
      for reference in response.data.responses[0].records
        all[reference.type][reference.id]

    all =
      Account: {}
      BankEntry: {}
      AccountEntry: {}

    Model =
      account:
        read: (opts={})->
          opts.resource = 'Account_v1'
          opts.action = 'read'

          $http.post('/api', JSON.stringify([ opts ]) ).then(handleApiResponse)

      bankEntry:
        read: (opts={})->
          opts.resource = 'BankEntry_v1'
          opts.action = 'read'

          $http.post('/api', JSON.stringify([ opts ]) ).then(handleApiResponse)

        save: (attrs, opts={})->
          opts.resource = 'BankEntry_v1'
          opts.action = 'update'

          opts.id = attrs.id
          opts.data = underscore(attrs)
          delete opts.data.balance_cents
          opts.data.account_entries_attributes = opts.data.account_entries
          delete opts.data.account_entries

          $http.post('/api', JSON.stringify([ opts ]) ).then(handleApiResponse)
    Object.defineProperty Model.account, 'all',
      get: ->
        return @_all if @_all?
        @read().then (all)=>
          $window.localStorage.setItem('Model.account.all', angular.toJson(all))
          @_all.splice(0,@all.length, all...)
        try
          @_all = angular.fromJson($window.localStorage.getItem('Model.account.all'))
        @_all ||= []
      enumerable: true
      configurable: false
    window.Model = Model
    Model

  .controller 'EntriesCtrl', ($scope, Model)->
    bankEntryOffset = 0

    $scope.loadMore = ->
      $scope.isLoadingEntries = true
      Model.bankEntry.read(limit: 30, offset: bankEntryOffset).then (entries)->
        $scope.entries.splice($scope.entries.length, 0, entries...)
        delete $scope.isLoadingEntries
      bankEntryOffset += 30

    $scope.loadMore()
    $scope.entries = []
    $scope.accounts = Model.account.all

    $scope.$on 'addEntry', ->
      today = (new Date).toJSON().slice(0,10)
      $scope.entries.unshift({ date: today, accountEntries: [{}] })

  .controller 'AccountsCtrl', ($scope, Model)->
    $scope.accounts = Model.account.all
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
    $scope.accounts = Model.account.all
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
