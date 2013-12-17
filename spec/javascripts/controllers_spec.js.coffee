#= require angular_app/controllers

describe 'AccountsController', ->
  $scope = undefined

  beforeEach module 'Ledger', 'LedgerServicesMock'

  beforeEach inject ($rootScope, $controller) ->
    $scope = $rootScope.$new()
    $controller 'AccountsController',
      $scope: $scope

  it 'sets $scope.groups to allAccounts', inject (allAccounts)->
    $scope.$digest()
    expect($scope.groups).toBe allAccounts


describe 'AccountController', ->
  $scope = APIRequest = undefined

  beforeEach module 'Ledger', 'LedgerServicesMock'

  beforeEach inject ($rootScope, $controller, _APIRequest_) ->
    APIRequest = _APIRequest_
    $scope = $rootScope.$new()
    $controller 'AccountController',
      $scope: $scope
      $routeParams: id: 'account id'

  it 'loads account from params', ->
    expect($scope.account.$then).toExist

    expect(APIRequest.requests.length).toEqual 2
    accountRequest = APIRequest.requests[0]
    expect(accountRequest.action).toBe 'read'
    expect(accountRequest.type  ).toBe 'account'
    expect(accountRequest.query ).toEqual id: 'account id'

    account = { name: 'the account' }
    accountRequest.deferred.resolve [ account ]
    $scope.$digest()
    expect($scope.account).toEqual account

  it 'loads AccountEntries from params', ->
    accountRequest = APIRequest.requests[0]
    accountRequest.deferred.resolve [ { name: 'the account' } ]

    accountEntryRequest = APIRequest.requests[1]
    expect(accountEntryRequest.action).toBe 'read'
    expect(accountEntryRequest.type  ).toBe 'account_entry'
    expect(accountEntryRequest.query ).toEqual account_id: 'account id'

    accountEntries = [
      { bank_entry_id: 1 }
      { bank_entry_id: 2 }
    ]
    accountEntryRequest.deferred.resolve accountEntries
    $scope.$digest()
    expect($scope.account.account_entries).toEqual accountEntries

  it 'loads BankEntries off of AccountEntries bank_entry_id', ->
    accountRequest = APIRequest.requests[0]
    accountRequest.deferred.resolve [ { name: 'the account' } ]

    accountEntryRequest = APIRequest.requests[1]
    accountEntryRequest.deferred.resolve [
      { bank_entry_id: 1 }
      { bank_entry_id: 2 }
      { bank_entry_id: 2 }
      { bank_entry_id: 3 }
      { bank_entry_id: 1 }
    ]
    $scope.$digest()

    bankEntryRequest = APIRequest.requests[2]
    expect(bankEntryRequest.action).toBe 'read'
    expect(bankEntryRequest.type  ).toBe 'bank_entry'
    expect(bankEntryRequest.query ).toEqual id: [ 1, 2, 2, 3, 1 ]

    bankEntries = [
      { id: 1, name: 'entry 1' }
      { id: 2, name: 'entry 2' }
      { id: 3, name: 'entry 3' }
    ]
    bankEntryRequest.deferred.resolve bankEntries
    $scope.$digest()
    expect($scope.account.account_entries[0].bank_entry).toEqual bankEntries[0]
    expect($scope.account.account_entries[1].bank_entry).toEqual bankEntries[1]
    expect($scope.account.account_entries[2].bank_entry).toEqual bankEntries[1]
    expect($scope.account.account_entries[3].bank_entry).toEqual bankEntries[2]
    expect($scope.account.account_entries[4].bank_entry).toEqual bankEntries[0]


describe 'EntriesController', ->
  $scope = APIRequest = undefined

  beforeEach module 'Ledger', 'LedgerServicesMock'

  beforeEach inject ($rootScope, $controller, _APIRequest_) ->
    APIRequest = _APIRequest_
    $scope = $rootScope.$new()
    $controller 'EntriesController',
      $scope: $scope
      $routeParams: page: 1

  it 'populates accounts', ->
    expect(APIRequest.requests.length).toEqual 2
    accountsRequest = APIRequest.requests[1]
    expect(accountsRequest.action).toBe 'read'
    expect(accountsRequest.type  ).toBe 'account'

    accounts = [ 1, 2, 4, 3 ]
    accountsRequest.deferred.resolve accounts
    $scope.$digest()
    expect($scope.accounts).toEqual accounts

  it 'loads page from params', ->
    entriesRequest = APIRequest.requests[0]
    expect(entriesRequest.action).toBe 'read'
    expect(entriesRequest.type  ).toBe 'bank_entry'
    expect(entriesRequest.offset).toBe 30

    bankEntries = [
      { external_id: 1 }
      { external_id: null }
    ]
    entriesRequest.deferred.resolve bankEntries
    $scope.$digest()
    expect($scope.entries).toBe bankEntries
    expect($scope.entries[0].isFromBank).toBe true
    expect($scope.entries[1].isFromBank).toBe false


describe 'EntryEditController', ->
  $scope = APIRequest = undefined

  beforeEach module 'Ledger', 'LedgerServicesMock'

  beforeEach inject ($rootScope, $controller, _APIRequest_) ->
    APIRequest = _APIRequest_
    $scope = $rootScope.$new()
    $scope.entry =
      ammount_cents: 300
      account_entries: [
        { id: 1, ammount_cents: 100, account_id: 1, account_name: 'First' }
        { id: 2, ammount_cents: 200, account_id: 2, account_name: 'Second' }
      ]
    $controller 'EntryEditController',
      $scope: $scope

  it 'creates newAccountEntry when there are extra cents', ->
    expect($scope.newAccountEntry).toBeNull()
    expect($scope.accountEntries.length).toEqual 2

    $scope.accountEntries[0].ammount_cents = 10
    $scope.accountEntryChanged()
    expect($scope.newAccountEntry.ammount_cents).toEqual 90
    expect($scope.accountEntries.length).toEqual 3
    expect($scope.accountEntries).toContain $scope.newAccountEntry

  it 'newAccountEntry accounts for "" in ammount_cents', ->
    $scope.accountEntries[0].ammount_cents = ''
    $scope.accountEntryChanged()
    expect($scope.newAccountEntry.ammount_cents).toEqual 100
    expect($scope.accountEntries.length).toEqual 3
    expect($scope.accountEntries).toContain $scope.newAccountEntry

  it 'updates newAccountEntry when ammount_cents changes', ->
    $scope.accountEntries[0].ammount_cents = 10
    $scope.accountEntryChanged()
    expect($scope.newAccountEntry.ammount_cents).toEqual 90
    expect($scope.accountEntries.length).toEqual 3
    expect($scope.accountEntries).toContain $scope.newAccountEntry

  it 'creates a new newAccountEntry when the old newAccountEntry gets udated', ->
    $scope.accountEntries[0].ammount_cents = 10
    $scope.accountEntryChanged()
    oldNewAccountEntry = $scope.newAccountEntry
    oldNewAccountEntry.ammount_cents = 20
    $scope.accountEntryChanged(oldNewAccountEntry)
    expect(oldNewAccountEntry.ammount_cents).toEqual 20
    expect($scope.newAccountEntry.ammount_cents).toEqual 70
    expect($scope.accountEntries.length).toEqual 4
    expect($scope.accountEntries).toContain oldNewAccountEntry
    expect($scope.accountEntries).toContain $scope.newAccountEntry

  it 'removes newAccountEntry when there are no extra cents', ->
    $scope.accountEntries[0].ammount_cents = 10
    $scope.accountEntryChanged()
    expect($scope.newAccountEntry).toBeDefined()
    $scope.accountEntries[0].ammount_cents = 100
    $scope.accountEntryChanged()
    expect($scope.newAccountEntry).toBeNull()
    expect($scope.accountEntries.length).toEqual 2

  it 'saves', ->
    expect(APIRequest.requests.length).toBe 0
    $scope.save()
    expect(APIRequest.requests.length).toBe 1
    updateRequest = APIRequest.requests[0]
    expect(updateRequest.action).toBe 'update'
    expect(updateRequest.type  ).toBe 'bank_entry'
    expect(updateRequest.data  ).toEqual
      account_entries_attributes: [
        { id: 1, ammount_cents: 100, account_id: 1 }
        { id: 2, ammount_cents: 200, account_id: 2 }
      ]

    accountEntriesResponse = [
      { ammount_cents:  50, account_id: 3 }
      { ammount_cents: 250, account_id: 4 }
    ]
    updateRequest.deferred.resolve account_entries: accountEntriesResponse
    $scope.$digest()
    expect($scope.entry.account_entries).toEqual accountEntriesResponse


describe 'EntryController', ->
  $scope = APIRequest = undefined

  beforeEach module 'Ledger', 'LedgerServicesMock'

  beforeEach inject ($rootScope, $controller, _APIRequest_) ->
    APIRequest = _APIRequest_
    $scope = $rootScope.$new()
    $controller 'EntryController',
      $scope: $scope
      $routeParams: id: 'entry id'

  it 'loads entry from params', ->
    expect(APIRequest.requests.length).toEqual 1
    entryRequest = APIRequest.requests[0]
    expect(entryRequest.action).toBe 'read'
    expect(entryRequest.type  ).toBe 'bank_entry'
    expect(entryRequest.query ).toEqual id: 'entry id'

    entry = { name: 'the entry' }
    entryRequest.deferred.resolve entry
    $scope.$digest()
    expect($scope.entry).toEqual entry

  it 'sets $scope.groups to allAccounts', inject (allAccounts)->
    $scope.$digest()
    expect($scope.groups).toBe allAccounts
