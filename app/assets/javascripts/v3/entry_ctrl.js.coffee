angular.module("ledger").controller 'EntryCtrl', ($scope, Model, $parse)->
  watchAEs = undefined
  amountRemainingCentsExpression = 'entry.amountCents - (entry.accountEntries | map:"amountCents" | sum)'

  reset = ->
    $scope.isOpen = false
    delete $scope.stashedEntry
    $scope.form?.$setPristine()

    $scope.amountCents = $scope.entry.amountCents
    $scope.from = for ae in $scope.entry.accountEntries when ae.amountCents < 0
      ae.accountName
    $scope.to = for ae in $scope.entry.accountEntries when ae.amountCents > 0
      $scope.amountCents += ae.amountCents if $scope.entry.amountCents == 0
      ae.accountName

    $scope.open() unless $scope.entry.id

  $scope.isEditable = -> !$scope.entries.isFromLocalStorage && !$scope.saving

  $scope.open = ->
    return if $scope.isOpen
    $scope.isOpen = true
    $scope.stashedEntry = angular.copy($scope.entry)
    watchAEs = $scope.$watch amountRemainingCentsExpression, (amountRemainingCents)->
      if amountRemainingCents
        if !$scope.form.amount? || $scope.form.amount.$dirty || $scope.form.account.$modelValue
          newAE = amountCents: amountRemainingCents
          $scope.entry.accountEntries.push( newAE )
        else
          lastAE = $scope.entry.accountEntries[$scope.entry.accountEntries.length-1]
          lastAE.amountCents += amountRemainingCents

  $scope.close = (e)->
    e.stopPropagation()
    watchAEs()
    if $scope.entry.id
      $scope.entry = $scope.stashedEntry
      reset()
    else
      index = $scope.entries.indexOf($scope.entry)
      $scope.entries.splice(index, 1)

  $scope.save = (e)->
    e.stopPropagation()
    $scope.entry.accountEntries.forEach (ae)->
      ae._destroy = true unless ae.amountCents
    $scope.entry.accountEntries = $scope.entry.accountEntries.filter (ae)->
      ae.id || (ae.amountCents && ae.accountName)
    promise = Model.BankEntry.save($scope.entry).then (bankEntries)->
      delete $scope.saving
      $scope.entry = bankEntries[0]
      reset()
    $scope.$root.$emit 'status',
      text: 'saving'
      promise: promise
    $scope.saving = true

  reset()
  $scope.open() if $parse(amountRemainingCentsExpression)($scope)
