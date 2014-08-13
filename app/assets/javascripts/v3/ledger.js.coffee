//= require ../bower_components/angular/angular
//= require ../bower_components/angular-animate/angular-animate

angular.module('ledger', ['ng', 'ngAnimate'])

  .filter 'join', ->
    (input)-> input?.join(', ')

  .filter 'sum', ->
    (input, prop)->
      input?.map((e)-> parseInt(e[prop]) || 0).reduce ((a, b)-> a+b), 0

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
        if strict || value.match /^\$?-?\d[\d,.]*$/
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
      ammountRemainingCentsExpression = 'entry.ammountCents - (entry.accountEntries | sum:"ammountCents")'

      reset = ->
        scope.isOpen = false
        delete scope.stashedEntry
        scope.form.$setPristine()

        scope.ammountCents = scope.entry.ammountCents
        scope.type = if !scope.entry.id
          'New'
        else if scope.ammountCents == 0
          'Transfered'
        else if scope.ammountCents > 0
          #FIXME: I'm not sure I like how this sounds: Recieved $5.00 to Doug Blow
          'Recieved'
        else
          'Spent'

        scope.from = for ae in scope.entry.accountEntries when ae.ammountCents < 0
          ae.accountName
        scope.to = for ae in scope.entry.accountEntries when ae.ammountCents > 0
          scope.ammountCents += ae.ammountCents
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
        scope.addAccountEntry() unless scope.entry.accountEntries.length
        watchAEs = scope.$watch ammountRemainingCentsExpression, (ammountRemainingCents)->
          scope.ammountRemainingCents = ammountRemainingCents
        selectAE(scope.entry.accountEntries[0])

      scope.close = (e)->
        e.stopPropagation()
        watchAEs()
        if scope.entry.id
          scope.entry = scope.stashedEntry
          reset()
        else
          index = scope.entries.indexOf(scope.entry)
          scope.entries.splice(index, 1)

      scope.addAccountEntry = ->
        newAE = ammountCents: scope.ammountRemainingCents
        scope.entry.accountEntries.push( newAE )
        selectAE(newAE)

      scope.save = (e)->
        e.stopPropagation()
        scope.entry.accountEntries.forEach (ae)->
          ae._destroy = true unless ae.ammountCents
        Model.bankEntry.save(scope.entry).then (bankEntry)->
          scope.entry = bankEntry
        reset()

      reset()
      scope.ammountRemainingCents = $parse(ammountRemainingCentsExpression)(scope)
      scope.open() if scope.ammountRemainingCents


  .factory 'Model', ($http)->
    underscore = (cObj)->
      return cObj unless angular.isObject(cObj)

      uObj = {}
      for name, val of cObj when name.charAt(0) != '$' && name != 'className'
        newName = name.replace /[A-Z]/g, (l)-> '_'+l.toLowerCase()
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

    account:
      read: (opts={})->
        opts.action = 'read'
        opts.type = 'account'

        $http.post('/api', {
          body: JSON.stringify([ opts ])
        }).then (response)->
          camelize(model) for model in response.data[0].data

    bankEntry:
      read: (opts={})->
        opts.action = 'read'
        opts.type = 'BankEntry_v1'

        $http.post('/api', {
          body: JSON.stringify([ opts ])
        }).then (response)->
          camelize(model) for model in response.data[0].data

      save: (attrs, opts={})->
        opts.action = 'update'
        opts.type = 'bank_entry'
        opts.id = attrs.id
        opts.data = underscore(attrs)
        opts.data.account_entries_attributes = opts.data.account_entries
        delete opts.data.account_entries

        $http.post('/api', {
          body: JSON.stringify([ opts ])
        }).then (response)->
          camelize(response.data[0].data)

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
    Model.account.read(limit: 100).then (accounts)-> $scope.accounts = accounts

    $scope.$on 'addEntry', ->
      today = (new Date).toJSON().slice(0,10)
      $scope.entries.unshift({ date: today, accountEntries: [] })

        #    lCurrency = $filter('lCurrency')
        #
        #    $scope.transactionSummary = (entry)->
        #      if entry.ammount_cents == 0
        #        "#{lCurrency(entry.amount_cents)} from #{entry.account_entries[0].account_name}"
        #      else
        #        "nope"
