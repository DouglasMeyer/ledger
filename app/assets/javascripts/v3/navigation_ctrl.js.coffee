angular.module('ledger').controller 'NavigationCtrl', ($scope)->

  $scope.showNav = false
  $scope.toggle = -> $scope.showNav = !$scope.showNav
