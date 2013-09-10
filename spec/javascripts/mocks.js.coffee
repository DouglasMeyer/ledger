requestIndex = 0
successCallbacks = {}

window.mockAPIRequest =
  requests: []
  read: (type, reference: reference, limit: limit, offset: offset, query: query, success: success) ->
    reference ||= 'ledger_services_api_request_'+(requestIndex++)
    this.requests.push
      reference: reference
      action: 'read'
      type: type
      limit: limit
      offset: offset
      query: query
    successCallbacks[reference] = success
    reference
  update: (type, reference: reference, query: query, data: data, success: success) ->
    reference ||= 'ledger_services_api_request_'+(requestIndex++)
    this.requests.push
      reference: reference
      action: 'update'
      type: type
      query: query
      data: data
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
