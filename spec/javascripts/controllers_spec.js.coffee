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
      ammount_cents: 1000
      account_entries: [
        { ammount_cents: 200 }
        { ammount_cents: 600 }
        { ammount_cents: 200 }
      ]
    controller = $controller 'EntryEditController',
      $scope: scope

  it 'creates a new AccountEntry when there are extra cents', ->
    expect(scope.newAccountEntry).toBeNull()
    expect(scope.entry.account_entries.length).toEqual 3

    scope.entry.account_entries[0].ammount_cents = 50
    scope.accountEntryChanged()
    expect(scope.newAccountEntry.ammount_cents).toEqual 150
    expect(scope.entry.account_entries.length).toEqual 4
    expect(scope.entry.account_entries).toContain scope.newAccountEntry

    scope.entry.account_entries[0].ammount_cents = ''
    scope.accountEntryChanged()
    expect(scope.newAccountEntry.ammount_cents).toEqual 200
    expect(scope.entry.account_entries.length).toEqual 4
    expect(scope.entry.account_entries).toContain scope.newAccountEntry

    scope.entry.account_entries[0].ammount_cents = 150
    scope.accountEntryChanged()
    expect(scope.newAccountEntry.ammount_cents).toEqual 50
    expect(scope.entry.account_entries.length).toEqual 4
    expect(scope.entry.account_entries).toContain scope.newAccountEntry

    oldNewAccountEntry = scope.newAccountEntry
    oldNewAccountEntry.ammount_cents = 25
    scope.accountEntryChanged(oldNewAccountEntry)
    expect(oldNewAccountEntry.ammount_cents).toEqual 25
    expect(scope.newAccountEntry.ammount_cents).toEqual 25
    expect(scope.entry.account_entries.length).toEqual 5
    expect(scope.entry.account_entries).toContain oldNewAccountEntry
    expect(scope.entry.account_entries).toContain scope.newAccountEntry

    scope.entry.account_entries[0].ammount_cents = 175
    scope.accountEntryChanged()
    expect(scope.newAccountEntry).toBeNull()
    expect(scope.entry.account_entries.length).toEqual 4
