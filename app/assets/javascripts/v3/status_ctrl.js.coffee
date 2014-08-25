angular.module('ledger').controller 'StatusCtrl', ($scope, $rootScope)->

  $scope.statuses = []
  $rootScope.$on 'status', (event, obj)->
    $scope.statuses.push obj
    obj.promise?.finally ->
      index = $scope.statuses.indexOf obj
      $scope.statuses.splice(index, 1)
