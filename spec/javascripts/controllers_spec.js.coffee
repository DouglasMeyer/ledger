#= require angular_app/controllers

describe 'AccountsController', ->
  scope = undefined
  controller = undefined

  beforeEach module('Ledger')

  beforeEach inject ($rootScope, $controller) ->
    mockAPIRequest.reset()

    scope = $rootScope.$new()
    controller = $controller 'AccountsController',
      $scope: scope
      APIRequest: mockAPIRequest

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

  beforeEach module('Ledger')

  beforeEach inject ($rootScope, $controller) ->
    mockAPIRequest.reset()

    scope = $rootScope.$new()
    controller = $controller 'AccountController',
      $scope: scope
      APIRequest: mockAPIRequest
      $routeParams: id: 'account id'

  it 'loads account from params', ->
    accountRequest = mockAPIRequest.requests[0]
    expect(accountRequest.action).toEqual 'read'
    expect(accountRequest.type  ).toEqual 'account'
    expect(accountRequest.query ).toEqual id: 'account id'

    account = { name: 'the account' }
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
