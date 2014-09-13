angular.module('ledger').controller 'ForecastCtrl', ($scope, Model)->

  $scope.$root.pageActions = [ {
    text: 'Add Projection'
    icon: 'plus'
    click: -> $scope.entries.unshift({})
  } ]

  Model.ProjectedEntry.read().then (entries)->
    $scope.entries = entries
