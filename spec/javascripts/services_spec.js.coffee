#= require angular_app/services

describe 'APIRequest', ->
  $httpBackend = $timeout = undefined

  beforeEach module 'LedgerServices'
  beforeEach inject ($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    $timeout = $injector.get '$timeout'

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()
    #$timeout.verifyNoPendingTasks()

  describe '.read', ->
    it 'makes requests', inject (APIRequest, $rootScope) ->
      promise = APIRequest.read 'account',
        reference: 'account request'
        query: id: 'the id'

      promiseResolved = false
      promise.then (data)->
        promiseResolved = true
        expect(data).toEqual 'the data'

      $httpBackend.expect('POST', '/api', body: JSON.stringify([
        reference: 'account request'
        action: 'read', type: 'account'
        query: id: 'the id'
      ])).respond([
        { reference: 'account request', data: 'the data' }
      ])
      $timeout.flush()
      $httpBackend.flush()
      $rootScope.$digest()

      expect(promiseResolved).toBe true

    it 'chains requests', inject (APIRequest) ->
      oneData = twoData = undefined
      APIRequest.read('account', reference: 'one')
        .then (data)-> oneData = data
      APIRequest.read('account', reference: 'two', query: id: 'the id')
        .then (data)-> twoData = data

      $httpBackend.expect('POST', '/api', body: JSON.stringify([
        { reference: 'one', action: 'read', type: 'account' }
        { reference: 'two', action: 'read', type: 'account', query: id: 'the id' }
      ])).respond([
        { reference: 'two', data: 'data 2' }
        { reference: 'one', data: 'data 1' }
      ])
      $timeout.flush()
      $httpBackend.flush()

      expect(oneData).toEqual 'data 1'
      expect(twoData).toEqual 'data 2'

  describe '.update', ->
    it 'make requests', inject (APIRequest) ->
      promiseCalled = false
      APIRequest.update('account',
        reference: 'account update'
        id: 'the id'
        data: this: 'that')
          .then (data)->
            promiseCalled = true
            expect(data).toEqual this: 'other'

      $httpBackend.expect('POST', '/api', body: JSON.stringify([
        reference: 'account update'
        action: 'update', type: 'account'
        id: 'the id'
        data: this: 'that'
      ])).respond([
        { reference: 'account update', data: { this: 'other' } }
      ])
      $timeout.flush()
      $httpBackend.flush()

      expect(promiseCalled).toEqual true


describe 'Account', ->
  APIRequest = undefined

  beforeEach module 'LedgerServices', 'LedgerServicesMock'
  beforeEach inject (_APIRequest_)->
    APIRequest = _APIRequest_

  describe '.find', ->
    it 'gives you a promise', inject (Account) ->
      account = Account.find 1
      expect(account.then).toBeDefined()

    it 'makes an APIRequest', inject (Account) ->
      account = Account.find 1
      request = APIRequest.requests[0]
      expect(request.action).toBe 'read'
      expect(request.type  ).toBe 'account'
      expect(request.query ).toEqual id: 1

    it 'resolves the promise with the server response', inject ($rootScope, Account) ->
      account = Account.find 1
      APIRequest.requests[0].deferred.resolve [ id: 1, name: 'account 1' ]
      $rootScope.$digest()

      expect(account.id).toEqual 1
      expect(account.name).toEqual 'account 1'

    it 'fetches from the cache', inject (Account) ->
      account = Account.find 1
      accountCopy = Account.find 1
      otherAccount = Account.find 2

      expect(accountCopy).toEqual account
      expect(otherAccount).not.toEqual account
