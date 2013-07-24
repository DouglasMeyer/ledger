window.Ledger.controller 'AccountsController', ($scope, $filter, APIRequest) ->
  $('body').attr 'class', 'accounts index'
  APIRequest.read('account'
    success: (data) ->
      order = $filter('orderBy')

      $scope.groups = { Assets: [], Liabilities: [] }
      for account in order(data, 'position')
        list = $scope.groups[if account.asset then 'Assets' else 'Liabilities']
        if account.category != list[list.length-1]?.category
          account.firstInCategory = true
        list.push account
  )

window.Ledger.controller 'AccountController', ($scope, $routeParams, APIRequest) ->
  $('body').attr 'class', 'accounts show'
  account_id = $routeParams.id

  APIRequest.read('account',
    query: { id: account_id }
    success: (data) -> $scope.account = data[0]
  )
  APIRequest.read('account_entry',
    query: { account_id: account_id }
    success: (data) ->
      account_entries = $scope.account.account_entries = data

      bank_entry_ids = []
      for ae in account_entries
        bank_entry_ids.push ae.bank_entry_id

      APIRequest.read('bank_entry',
        query: { id: bank_entry_ids }
        success: (data) ->
          for bank_entry in data
            for account_entry in account_entries when account_entry.bank_entry_id == bank_entry.id
              account_entry.bank_entry = bank_entry
      )
  )

window.Ledger.controller 'EntriesController', ($scope, APIRequest) ->
  $('body').attr 'class', 'bank_entries index'
  APIRequest.read('bank_entry'
    success: (data) ->
      entries = $scope.entries = data

      #for entry in entries
      #  APIRequest.read('account_entry'
      #    query: { bank_entry_id: entry.id }
      #    success: (data) -> entry.account_entries = data
      #  )
  )

  $scope.save = (entry) ->
    console.log entry
