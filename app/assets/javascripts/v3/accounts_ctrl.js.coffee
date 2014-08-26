angular.module('ledger').controller 'AccountsCtrl', ($scope, Model, $window)->
  $scope.accounts = Model.Account.all

  $scope.$root.$emit 'status',
    text: 'loading'
    promise: $scope.accounts.promise

  $scope.$root.pageActions = [ {
    text: 'Edit Accounts'
    icon: 'pencil'
    click: -> $window.location = '/v3/accounts/edit'
  } ]

  $scope.$watchCollection 'accounts | orderBy:"position"', (accounts)->
    $scope.assetCategories = []
    $scope.liabilityCategories = []
    for account in accounts
      category = account.category
      categories = if account.asset then $scope.assetCategories else $scope.liabilityCategories
      categories.push(category) unless category in categories
