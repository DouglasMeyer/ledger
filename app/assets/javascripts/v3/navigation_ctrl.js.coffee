angular.module('ledger').controller 'NavigationCtrl', ($scope, entriesNeedingDistribution)->

  $scope.showNav = false
  $scope.toggle = -> $scope.showNav = !$scope.showNav

  $scope.entriesNeedingDistribution = entriesNeedingDistribution
  $scope.$watchCollection 'entriesNeedingDistribution.length', (distributionCount)->
    $scope.distributionCount = distributionCount || 0
