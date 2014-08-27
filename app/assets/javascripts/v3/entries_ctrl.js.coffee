angular.module('ledger').controller 'EntriesCtrl', ($scope, Model)->
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
    Model.BankEntry.read(limit: 30, offset: $scope.entries.length).then ->
      delete $scope.isLoadingEntries

  $scope.entries = Model.BankEntry.all
  $scope.accounts = Model.Account.all
