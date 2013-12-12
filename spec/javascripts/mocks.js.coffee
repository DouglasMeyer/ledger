(window.LedgerServices ||= {}).mock = {}

LedgerServices.mock.APIRequestProvider = ->

  @$get = ($q)->
    apiCall = (action, type, options)->
      request = angular.copy options
      request.action = action
      request.type = type
      request.deferred = $q.defer()

      APIRequest.requests.push request
      request.deferred.promise

    APIRequest =
      requests: []
      read: (type, options={})-> apiCall('read', type, options)
      update: (type, options={})-> apiCall('update', type, options)
    APIRequest
  undefined

angular.module('LedgerServicesMock', ['ng']).provider
  APIRequest: LedgerServices.mock.APIRequestProvider
