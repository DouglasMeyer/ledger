angular.module('LedgerServices', [])
  .service 'APIRequest', ($http, $window, $rootScope) ->

    timeout = undefined
    requests = []
    successCallbacks = {}
    requestIndex = 0

    prepareToPost = ->
      $window.clearTimeout(timeout) if timeout
      timeout = $window.setTimeout post, 100

    post = ->
      timeout = undefined
      requestsNow = requests
      requests = []
      successCallbacksNow = successCallbacks
      successCallbacks = {}
      $http
        .post('/api', body: JSON.stringify(requestsNow))
        .success (response) ->
          for data in response
            successCallbacksNow[data.reference]?(data.data)
      $rootScope.$apply()
      undefined

    this.read = (type, reference: reference, query: query, success: success) ->
      reference ||= 'ledger_services_api_request_'+(requestIndex++)
      requests.push
        reference: reference
        action: 'read'
        type: type
        query: query
      successCallbacks[reference] = success
      prepareToPost()
      reference

    this.post = ->
      $window.clearTimeout(timeout) if timeout
      post()

  .factory 'Account', (APIRequest, $q) ->
    cache = {}

    class Account
      constructor: ->

    Account.find = (id) ->
      return cache[id] if cache[id]

      value = cache[id] = new Account

      deferred = $q.defer()
      markResolved = -> value.$resolved = true; undefined
      value.$resolved = false
      deferred.promise.then(markResolved, markResolved)

      APIRequest.read 'account',
        query: id: id
        success: (data) ->
          deferred.resolve data[0]

      value.$then = deferred.promise.then( (data)->
        angular.copy data, value

        data
      ).then

      value

    Account
