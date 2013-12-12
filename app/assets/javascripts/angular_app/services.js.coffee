angular.module('LedgerServices', [])
  .service 'APIRequest', ($http, $timeout, $q, $rootScope) ->

    timeout = undefined
    requests = []
    deferredRequests = {}
    requestIndex = 0

    prepareToPost = ->
      $timeout.cancel timeout if timeout
      timeout = $timeout post, 100

    post = ->
      timeout = undefined
      requestsNow = requests
      requests = []
      deferredRequestsNow = deferredRequests
      deferredRequests = {}
      $http
        .post('/api', body: JSON.stringify(requestsNow))
        .success (response) ->
          for data in response
            deferredRequestsNow[data.reference]?.resolve(data.data)
      $rootScope.$apply()
      undefined

    @read = (type, reference: reference, query: query, limit: limit, offset: offset) ->
      deferred = $q.defer()
      reference ||= 'ledger_services_api_request_'+(requestIndex++)
      requests.push
        reference: reference
        action: 'read'
        type: type
        limit: limit
        offset: offset
        query: query
      deferredRequests[reference] = deferred
      prepareToPost()
      deferred.promise

    @update = (type, reference: reference, id: id, data: data) ->
      deferred = $q.defer()
      reference ||= 'ledger_services_api_request_'+(requestIndex++)
      requests.push
        reference: reference
        action: 'update'
        type: type
        id: id
        data: data
      deferredRequests[reference] = deferred
      prepareToPost()
      deferred.promise

    @post = ->
      $timeout.cancel timeout if timeout
      post()

    this

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

      APIRequest
        .read('account', query: id: id)
        .then (data)-> deferred.resolve data[0]

      value.then = deferred.promise.then( (data)->
        angular.copy data, value

        data
      ).then

      value

    Account
