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
