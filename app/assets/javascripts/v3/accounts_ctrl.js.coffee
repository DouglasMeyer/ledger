angular.module('ledger').controller 'AccountsCtrl', ($scope, Model)->
  $scope.accounts = Model.Account.all
  $scope.$watchCollection 'accounts | orderBy:"position"', (accounts)->
    $scope.assetCategories = []
    $scope.liabilityCategories = []
    for account in accounts
      category = account.category
      categories = if account.asset then $scope.assetCategories else $scope.liabilityCategories
      categories.push(category) unless category in categories
