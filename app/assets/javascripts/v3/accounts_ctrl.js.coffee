angular.module('ledger').controller 'AccountsCtrl', ($scope, Model, $window)->
  $scope.accounts = Model.Account.all

  $scope.$root.pageActions = [ {
    text: 'Edit Accounts'
    icon: 'pencil'
    click: -> $window.location = '#/accounts/edit'
  } ]

  $scope.$watchCollection 'accounts | orderBy:"position"', (accounts)->
    $scope.assetCategories = []
    $scope.liabilityCategories = []
    for account in accounts
      category = account.category
      categories = if account.asset then $scope.assetCategories else $scope.liabilityCategories
      categories.push(category) unless category in categories
