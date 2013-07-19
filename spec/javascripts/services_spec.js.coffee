#= require angular_app/services

describe 'APIRequest', ->
  httpBackend = undefined
  mockWindow = {
    navigator: window.navigator
    timeouts: []
    setTimeout: (fn, time) ->
      timeout = fn: fn, time: time
      @timeouts.push timeout
      timeout
    clearTimeout: (timeout) ->
      index = @timeouts.indexOf timeout
      @timeouts.splice index, 1 if index != -1
    flush: ->
      angular.forEach @timeouts, (timeout) ->
        timeout.fn()
      @timeouts = []
  }

  beforeEach module 'LedgerServices', ($provide) ->
    $provide.value '$window', mockWindow
    null
  beforeEach inject ($injector) ->
    httpBackend = $injector.get '$httpBackend'

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe '.read', ->
    it 'makes requests', inject ($window, APIRequest) ->
      successCalled = false
      reference = APIRequest.read 'account',
        reference: 'account request'
        query: id: 'the id'
        success: -> successCalled = true
      expect($window.timeouts.length).toEqual 1

      httpBackend.expect('POST', '/api', body: JSON.stringify([
        reference: 'account request'
        action: 'read', type: 'account'
        query: id: 'the id'
      ])).respond([
        { reference: 'account request', data: 'the data' }
      ])
      $window.flush()
      httpBackend.flush()

      expect(successCalled).toEqual true

    it 'chains requests', inject ($window, APIRequest) ->
      oneData = twoData = undefined
      APIRequest.read 'account',
        reference: 'one'
        success: (data) -> oneData = data
      expect($window.timeouts.length).toEqual 1
      APIRequest.read 'account',
        reference: 'two'
        query: id: 'the id'
        success: (data) -> twoData = data
      expect($window.timeouts.length).toEqual 1

      httpBackend.expect('POST', '/api', body: JSON.stringify([
        { reference: 'one', action: 'read', type: 'account' }
        { reference: 'two', action: 'read', type: 'account', query: id: 'the id' }
      ])).respond([
        { reference: 'two', data: 'data 2' }
        { reference: 'one', data: 'data 1' }
      ])
      $window.flush()
      httpBackend.flush()

      expect(oneData).toEqual 'data 1'
      expect(twoData).toEqual 'data 2'
