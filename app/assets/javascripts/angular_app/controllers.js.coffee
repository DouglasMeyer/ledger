window.Ledger.controller 'AccountsController', ['$scope', '$http', ($scope, $http) ->
  $('body').attr 'class', 'accounts index'
  $http
    .post('/api',
      body: JSON.stringify([
        action: 'read', type: 'account'
      ])
    )
    .success (data) ->
      $scope.accounts = data[0].data
]

window.Ledger.controller 'AccountController', ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
  $('body').attr 'class', 'accounts show'
  account_id = $routeParams.id
  $http
    .post('/api',
      body: JSON.stringify([
        action: 'read', type: 'account', query: { id: account_id }
      ,
        action: 'read', type: 'account_entry', query: { account_id: account_id }
      ])
    )
    .success (data) ->
      $scope.account = data[0].data[0]
      account_entries = $scope.account.account_entries = data[1].data

      bank_entry_ids = []
      for ae in account_entries
        bank_entry_ids.push ae.bank_entry_id

      $http
        .post('/api',
          body: JSON.stringify([
            action: 'read', type: 'bank_entry', query: { id: bank_entry_ids }
          ])
        )
        .success (data) ->
          for bank_entry in data[0].data
            for account_entry in account_entries when account_entry.bank_entry_id == bank_entry.id
              account_entry.bank_entry = bank_entry
]
