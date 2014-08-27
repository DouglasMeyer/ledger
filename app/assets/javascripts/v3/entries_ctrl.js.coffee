angular.module('ledger').controller 'EntriesCtrl', ($scope, Model, $window)->
  bankEntryOffset = 0

  $scope.$root.pageActions = [ {
    text: 'Add Entry'
    icon: 'plus'
    click: ->
      today = (new Date).toJSON().slice(0,10)
      $scope.entries.unshift({ date: today, amountCents: 0, accountEntries: [{}] })
  } ]

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
    $scope.$root.$emit 'status',
      text: 'loading'
      promise: promise
    bankEntryOffset += 30
    promise

  try
    $scope.entries = Model.BankEntry.load(angular.fromJson($window.localStorage.getItem('EntriesCtrl.entries')))
    $scope.entriesFromLocalStorage = true
  $scope.entries ||= []
  $scope.loadMore().then (entries)->
    try
      $window.localStorage.setItem('EntriesCtrl.entries', angular.toJson(entries))
    oldEntries = $scope.entries.filter (entry)-> entry not in entries
    for entry in oldEntries
      index = $scope.entries.indexOf(entry)
      $scope.entries.splice(index, 1)
    delete $scope.entriesFromLocalStorage
  $scope.accounts = Model.Account.all
