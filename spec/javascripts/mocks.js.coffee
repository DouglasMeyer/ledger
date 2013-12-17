(window.LedgerServices ||= {}).mock = {}

LedgerServices.mock =

  APIRequestProvider: ->
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

  allAccounts: ->
    @$get = ($q)->
      deffered = $q.defer()
      deffered.resolve {
        Assets: [
          { position: 1, asset: true,  category: 'Thing', name: 'thing 1' }
          { position: 2, asset: true,  category: 'Thing', name: 'thing 2' }
        ]
        Liabilities: [
          { position: 1, asset: false, category: 'Thing', name: 'thing' }
          { position: 2, asset: false, category: 'Other Thing', name: 'something' }
        ]
      }
      deffered.promise
    undefined

angular.module('LedgerServicesMock', ['ng']).provider
  APIRequest: LedgerServices.mock.APIRequestProvider
  allAccounts: LedgerServices.mock.allAccounts
