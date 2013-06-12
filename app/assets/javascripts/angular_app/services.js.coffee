angular.module('LedgerServices', [])
  .service 'APIRequest', [ '$http', ($http) ->

    timeout = undefined
    requests = []
    successCallbacks = {}
    requestIndex = 0

    prepareToPost = ->
      clearTimeout(timeout) if timeout
      timeout = setTimeout post, 100

    post = ->
      timeout = undefined
      requestsNow = requests
      requests = []
      successCallbacksNow = successCallbacks
      successCallbacks = {}
      jqxhr = $http
        .post('/api', body: JSON.stringify(requestsNow))
        .success (response) ->
          for data in response
            successCallbacksNow[data.reference]?(data.data)
      jqxhr

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
      clearTimeout(timeout) if timeout
      post()
  ]
