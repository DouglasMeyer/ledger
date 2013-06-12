angular.module('ledgerServices', []).
  factory('Account', ($http) ->
    $http.post('/api', { body: [
      action: 'read',
        type: 'account'
    ] }).
    success (data) ->
  )
