angular.module('LedgerServices', [])
  .service 'APIRequest', [ '$http', ($http) ->

    timeout = undefined
    requests = []
    successCallbacks = []

    prepareToPost = ->
      clearTimeout(timeout) if timeout
      timeout = setTimeout post, 100

    post = ->
      timeout = undefined
      requestsNow = requests
      requests = []
      successCallbacksNow = successCallbacks
      successCallbacks = []
      jqxhr = $http
        .post('/api', body: JSON.stringify(requestsNow))
        .success (response) ->
          for data, index in response
            successCallbacksNow[index](data.data)
      jqxhr

    this.read = (type, query: query, success: success) ->
      requests.push
        action: 'read'
        type: type
        query: query
      successCallbacks.push success || ->
      prepareToPost()
      this

    this.post = ->
      clearTimeout(timeout) if timeout
      post()
  ]
