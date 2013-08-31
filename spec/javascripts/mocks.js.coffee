requestIndex = 0
successCallbacks = {}

window.mockAPIRequest =
  requests: []
  read: (type, reference: reference, query: query, success: success) ->
    reference ||= 'ledger_services_api_request_'+(requestIndex++)
    this.requests.push
      reference: reference
      action: 'read'
      type: type
      query: query
    successCallbacks[reference] = success
    reference
  post: ->

  reset: ->
    requestIndex = 0
    successCallbacks = {}
    @requests = []

  satisfyRequest: (request, response) ->
    index = @requests.indexOf(request)
    if index != -1
      @requests.splice index, 1

    successCallbacks[request.reference](response)
