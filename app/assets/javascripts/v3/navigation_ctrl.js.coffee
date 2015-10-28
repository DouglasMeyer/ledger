# coffeelint: disable=max_line_length
angular.module('ledger')
.controller 'NavigationCtrl', ($scope, entriesNeedingDistribution, ledgerSummary)->

  $scope.showNav = false
  $scope.toggle = -> $scope.showNav = !$scope.showNav

  $scope.entriesNeedingDistribution = entriesNeedingDistribution
  $scope.$watchCollection 'entriesNeedingDistribution.length', (distributionCount)->
    $scope.distributionCount = distributionCount || 0

  $scope.ledgerSummary = ledgerSummary
  $scope.$watch 'ledgerSummary.latest_bank_import.balance_cents - ledgerSummary.ledger_sum_cents', (bankDelta)->
    $scope.bankDelta = bankDelta
# coffeelint: enable=max_line_length
