window.Ledger.controller 'NavigationCtrl', ($scope, $rootScope, $location)->
  $rootScope.$on '$locationChangeSuccess', ->
    $scope.locationPath = $location.path()

window.Ledger.controller 'AccountsController', ($scope, $filter, APIRequest) ->
  $('body').attr 'class', 'accounts index'
  APIRequest.read('account'
    limit: 1000
    success: (data) ->
      order = $filter('orderBy')

      $scope.groups = { Assets: [], Liabilities: [] }
      for account in order(data, 'position')
        list = $scope.groups[if account.asset then 'Assets' else 'Liabilities']
        if account.category != list[list.length-1]?.category
          account.firstInCategory = true
        list.push account
  )

window.Ledger.controller 'AccountController', ($scope, $routeParams, APIRequest, Account) ->
  $('body').attr 'class', 'accounts show'
  account_id = $routeParams.id

  $scope.account = Account.find account_id
  APIRequest.read('account_entry',
    query: { account_id: account_id }
    success: (data) ->
      account_entries = $scope.account.account_entries = data

      bank_entry_ids = []
      for ae in account_entries
        bank_entry_ids.push ae.bank_entry_id

      APIRequest.read('bank_entry',
        query: { id: bank_entry_ids }
        success: (data) ->
          for bank_entry in data
            for account_entry in account_entries when account_entry.bank_entry_id == bank_entry.id
              account_entry.bank_entry = bank_entry
      )
  )

window.Ledger.controller 'EntriesController', ($scope, $routeParams, $location, APIRequest) ->
  $('body').attr 'class', 'bank_entries index'
  limit = 30
  page = parseInt($routeParams.page||0, 10)||0

  APIRequest.read('bank_entry'
    limit: limit
    offset: page * limit
    success: (data) ->
      $scope.entries = data
      for entry in $scope.entries
        entry.isFromBank = entry.external_id != null
      $scope.hasPreviousPage = true if page > 0
      $scope.hasNextPage     = true if $scope.entries.length == limit
  )
  APIRequest.read 'account', success: (data) -> $scope.accounts = data

  $scope.gotoPreviousPage = -> $location.search(page: page - 1)
  $scope.gotoNextPage     = -> $location.search(page: page + 1)

  $scope.edit = (entry) -> entry.isEditing = true
  $scope.cancelEdit = (entry) -> delete entry.isEditing

window.Ledger.controller 'EntryEditController', ($scope, APIRequest) ->
  $scope.accountEntries = angular.copy($scope.entry.account_entries)
  $scope.newAccountEntry = null

  $scope.accountEntryChanged = (chanegdAE) ->
    if chanegdAE == $scope.newAccountEntry
      $scope.newAccountEntry = null
    remainingCents = $scope.entry.ammount_cents
    for ae in $scope.accountEntries when ae != $scope.newAccountEntry
      remainingCents -= parseInt(ae.ammount_cents, 10) || 0
    if remainingCents == 0
      if $scope.newAccountEntry
        $scope.accountEntries.pop()
        $scope.newAccountEntry = null
    else
      if $scope.newAccountEntry
        $scope.newAccountEntry.ammount_cents = remainingCents
      else
        $scope.newAccountEntry = ammount_cents: remainingCents
        $scope.accountEntries.push $scope.newAccountEntry

  $scope.accountEntryChanged()

  $scope.save = ->
    savingEntry = {} #TODO: date and notes
    savingEntry.account_entries_attributes = []
    for accountEntry in $scope.accountEntries
      savingEntry.account_entries_attributes.push
        id:            accountEntry.id
        ammount_cents: accountEntry.ammount_cents
        account_id:    accountEntry.account_id
        _destroy:      true unless accountEntry.ammount_cents

    APIRequest.update 'bank_entry',
      id: $scope.entry.id
      data: savingEntry
      success: (data) ->
        angular.copy data, $scope.entry
