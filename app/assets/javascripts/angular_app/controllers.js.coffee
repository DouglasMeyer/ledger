window.Ledger.controller 'AccountsController', ['$scope', '$http', ($scope, $http) ->
  $http
    .post('/api',
      body: JSON.stringify([
        action: 'read', type: 'account'
      ])
    )
    .success (data) ->
      $scope.accounts = data[0].data
]
