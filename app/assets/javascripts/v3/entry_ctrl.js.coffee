angular.module("ledger").controller 'EntryCtrl', ($scope, Model, $parse, entriesNeedingDistribution)->

  $scope.accounts = Model.Account.all
  $scope.$watchCollection 'accounts | filter:{isDeleted:false} | pMap:"name" | orderBy', (accountNames)->
    $scope.accountNames = accountNames
  $scope.isEditable = -> !$scope.entries.isFromLocalStorage && !$scope.saving

  watchAEs = undefined
  amountRemainingCentsExpression = 'editingEntry.amountCents - (editingEntry.accountEntries | map:"amountCents" | sum)'

  autoOpen = ->
    $scope.open() if $scope.isEditable() && (!$scope.entry.id || $parse(amountRemainingCentsExpression)($scope))

  reset = ->
    $scope.isOpen = false
    $scope.editingEntry = angular.copy($scope.entry)
    $scope.form?.$setPristine()

    $scope.amountCents = $scope.entry.amountCents
    $scope.from = for ae in $scope.entry.accountEntries when ae.amountCents < 0
      ae.accountName
    $scope.to = for ae in $scope.entry.accountEntries when ae.amountCents > 0
      $scope.amountCents += ae.amountCents if $scope.entry.amountCents == 0
      ae.accountName

  removeEntry = ->
    index = $scope.entries.indexOf($scope.entry)
    $scope.entries.splice(index, 1)

  $scope.open = ->
    return if $scope.isOpen
    $scope.isOpen = true
    watchAEs = $scope.$watch amountRemainingCentsExpression, (amountRemainingCents)->
      if amountRemainingCents
        if !$scope.form.amount? || $scope.form.amount.$dirty || $scope.form.account.$modelValue
          newAE = amountCents: amountRemainingCents
          $scope.editingEntry.accountEntries.push( newAE )
        else if lastAE = $scope.editingEntry.accountEntries[$scope.editingEntry.accountEntries.length-1]
          lastAE.amountCents += amountRemainingCents

  $scope.close = (e)->
    e.stopPropagation()
    watchAEs()
    if $scope.entry.id
      reset()
    else
      removeEntry()

  $scope.save = (e)->
    e.stopPropagation()
    $scope.editingEntry.accountEntries.forEach (ae)->
      ae._destroy = true unless ae.amountCents
    $scope.editingEntry.accountEntries = $scope.editingEntry.accountEntries.filter (ae)->
      ae.id || (ae.amountCents && ae.accountName)
    shouldDeleteEntry =
      !$scope.editingEntry.externalId &&
      $scope.editingEntry.accountEntries.every (ae)-> ae._destroy
    promise = if shouldDeleteEntry
      Model.BankEntry.destroy($scope.editingEntry).then ->
        removeEntry()
    else
      Model.BankEntry.save($scope.editingEntry).then (bankEntries)->
        if !$scope.editingEntry.id
          removeEntry()
        delete $scope.saving
        $scope.entry = bankEntries[0]
        reset()
    Model.BankEntry.read(needsDistribution: true).then (entries)->
      oldLength = entriesNeedingDistribution.length
      args = [0,oldLength].concat(entries)
      entriesNeedingDistribution.splice.apply(entriesNeedingDistribution, args)
    $scope.$root.$emit 'status',
      text: 'saving'
      promise: promise
    $scope.saving = true

  reset()
  autoOpen()
  if $scope.entries.isFromLocalStorage
    destroyWatchFromLocalStorage = $scope.$watch 'entries.isFromLocalStorage', (isFromLocalStorage)->
      return if isFromLocalStorage
      destroyWatchFromLocalStorage()
      reset()
      autoOpen()
  $scope.$on '$destroy', ->
    removeEntry() if !$scope.editingEntry.id
