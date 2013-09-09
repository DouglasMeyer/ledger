#= require angular_app/controllers

describe 'AccountsController', ->
  scope = undefined
  controller = undefined

  beforeEach module 'Ledger', ($provide) ->
    $provide.value 'APIRequest', mockAPIRequest
    undefined

  beforeEach inject ($rootScope, $controller) ->
    mockAPIRequest.reset()

    scope = $rootScope.$new()
    controller = $controller 'AccountsController',
      $scope: scope

  it 'sets $scope.groups', ->
    thing2    = { position: 2, asset: true,  category: 'Thing', name: 'thing 2' }
    thing     = { position: 1, asset: false, category: 'Thing', name: 'thing' }
    thing1    = { position: 1, asset: true,  category: 'Thing', name: 'thing 1' }
    something = { position: 2, asset: false, category: 'Other Thing', name: 'something' }
    request = mockAPIRequest.requests[0]
    mockAPIRequest.satisfyRequest request, [ thing2, thing, thing1, something ]

    expect(scope.groups).toEqual {
      Assets: [ thing1, thing2 ]
      Liabilities: [ thing, something ]
    }



describe 'AccountController', ->
  scope = undefined
  controller = undefined

  beforeEach module 'Ledger', ($provide) ->
    $provide.value 'APIRequest', mockAPIRequest
    undefined

  beforeEach inject ($rootScope, $controller) ->
    mockAPIRequest.reset()

    scope = $rootScope.$new()
    controller = $controller 'AccountController',
      $scope: scope
      $routeParams: id: 'account id'

  it 'loads account from params', ->
    expect(scope.account.$then).toExist

    expect(mockAPIRequest.requests.length).toEqual 2
    accountRequest = mockAPIRequest.requests[0]
    expect(accountRequest.action).toEqual 'read'
    expect(accountRequest.type  ).toEqual 'account'
    expect(accountRequest.query ).toEqual id: 'account id'

    account = { name: 'the account' }
    scope.$apply ->
      mockAPIRequest.satisfyRequest accountRequest, [ account ]
    expect(scope.account).toEqual account

  it 'loads AccountEntries from params', ->
    accountRequest = mockAPIRequest.requests[0]
    mockAPIRequest.satisfyRequest accountRequest, [ { name: 'the account' } ]

    accountEntryRequest = mockAPIRequest.requests[0]
    expect(accountEntryRequest.action).toEqual 'read'
    expect(accountEntryRequest.type  ).toEqual 'account_entry'
    expect(accountEntryRequest.query ).toEqual account_id: 'account id'

    accountEntries = [
      { bank_entry_id: 1 }
      { bank_entry_id: 2 }
    ]
    mockAPIRequest.satisfyRequest accountEntryRequest, accountEntries
    expect(scope.account.account_entries).toEqual accountEntries

  it 'loads BankEntries off of AccountEntries bank_entry_id', ->
    accountRequest = mockAPIRequest.requests[0]
    mockAPIRequest.satisfyRequest accountRequest, [ { name: 'the account' } ]

    accountEntryRequest = mockAPIRequest.requests[0]
    mockAPIRequest.satisfyRequest accountEntryRequest, [
      { bank_entry_id: 1 }
      { bank_entry_id: 2 }
      { bank_entry_id: 2 }
      { bank_entry_id: 3 }
      { bank_entry_id: 1 }
    ]

    bankEntryRequest = mockAPIRequest.requests[0]
    expect(bankEntryRequest.action).toEqual 'read'
    expect(bankEntryRequest.type  ).toEqual 'bank_entry'
    expect(bankEntryRequest.query ).toEqual id: [ 1, 2, 2, 3, 1 ]

    bankEntries = [
      { id: 1, name: 'entry 1' }
      { id: 2, name: 'entry 2' }
      { id: 3, name: 'entry 3' }
    ]
    mockAPIRequest.satisfyRequest bankEntryRequest, bankEntries
    expect(scope.account.account_entries[0].bank_entry).toEqual bankEntries[0]
    expect(scope.account.account_entries[1].bank_entry).toEqual bankEntries[1]
    expect(scope.account.account_entries[2].bank_entry).toEqual bankEntries[1]
    expect(scope.account.account_entries[3].bank_entry).toEqual bankEntries[2]
    expect(scope.account.account_entries[4].bank_entry).toEqual bankEntries[0]


describe 'EntriesController', ->
  scope = controller = undefined

  beforeEach module 'Ledger', ($provide) ->
    $provide.value 'APIRequest', mockAPIRequest
    undefined

  beforeEach inject ($rootScope, $controller) ->
    mockAPIRequest.reset()

    scope = $rootScope.$new()
    controller = $controller 'EntriesController', $scope: scope

  it 'populates accounts', ->
    expect(mockAPIRequest.requests.length).toEqual 2
    accountsRequest = mockAPIRequest.requests[1]
    expect(accountsRequest.action).toEqual 'read'
    expect(accountsRequest.type  ).toEqual 'account'

    accounts = [ 1, 2, 4, 3 ]
    scope.$apply ->
      mockAPIRequest.satisfyRequest accountsRequest, accounts
    expect(scope.accounts).toEqual accounts


describe 'EntryEditController', ->
  scope = undefined
  controller = undefined

  beforeEach module 'Ledger', ($provide) ->
    $provide.value 'APIRequest', mockAPIRequest
    undefined

  beforeEach inject ($rootScope, $controller) ->
    mockAPIRequest.reset()

    scope = $rootScope.$new()
    scope.entry =
      ammount_cents: 300
      account_entries: [
        { id: 1, ammount_cents: 100, account_id: 1, account_name: 'First' }
        { id: 2, ammount_cents: 200, account_id: 2, account_name: 'Second' }
      ]
    controller = $controller 'EntryEditController',
      $scope: scope

  it 'creates newAccountEntry when there are extra cents', ->
    expect(scope.newAccountEntry).toBeNull()
    expect(scope.accountEntries.length).toEqual 2

    scope.accountEntries[0].ammount_cents = 10
    scope.accountEntryChanged()
    expect(scope.newAccountEntry.ammount_cents).toEqual 90
    expect(scope.accountEntries.length).toEqual 3
    expect(scope.accountEntries).toContain scope.newAccountEntry

  it 'newAccountEntry accounts for "" in ammount_cents', ->
    scope.accountEntries[0].ammount_cents = ''
    scope.accountEntryChanged()
    expect(scope.newAccountEntry.ammount_cents).toEqual 100
    expect(scope.accountEntries.length).toEqual 3
    expect(scope.accountEntries).toContain scope.newAccountEntry

  it 'updates newAccountEntry when ammount_cents changes', ->
    scope.accountEntries[0].ammount_cents = 10
    scope.accountEntryChanged()
    expect(scope.newAccountEntry.ammount_cents).toEqual 90
    expect(scope.accountEntries.length).toEqual 3
    expect(scope.accountEntries).toContain scope.newAccountEntry

  it 'creates a new newAccountEntry when the old newAccountEntry gets udated', ->
    scope.accountEntries[0].ammount_cents = 10
    scope.accountEntryChanged()
    oldNewAccountEntry = scope.newAccountEntry
    oldNewAccountEntry.ammount_cents = 20
    scope.accountEntryChanged(oldNewAccountEntry)
    expect(oldNewAccountEntry.ammount_cents).toEqual 20
    expect(scope.newAccountEntry.ammount_cents).toEqual 70
    expect(scope.accountEntries.length).toEqual 4
    expect(scope.accountEntries).toContain oldNewAccountEntry
    expect(scope.accountEntries).toContain scope.newAccountEntry

  it 'removes newAccountEntry when there are no extra cents', ->
    scope.accountEntries[0].ammount_cents = 10
    scope.accountEntryChanged()
    expect(scope.newAccountEntry).toBeDefined()
    scope.accountEntries[0].ammount_cents = 100
    scope.accountEntryChanged()
    expect(scope.newAccountEntry).toBeNull()
    expect(scope.accountEntries.length).toEqual 2

  it 'saves', ->
    expect(mockAPIRequest.requests.length).toBe 0
    scope.save()
    expect(mockAPIRequest.requests.length).toBe 1
    updateRequest = mockAPIRequest.requests[0]
    expect(updateRequest.action).toEqual 'update'
    expect(updateRequest.type  ).toEqual 'bank_entry'
    expect(updateRequest.data  ).toEqual
      account_entries_attributes: [
        { id: 1, ammount_cents: 100, account_id: 1 }
        { id: 2, ammount_cents: 200, account_id: 2 }
      ]
