angular.module('ledger').controller 'StatusCtrl', ($scope, $rootScope)->

  $rootScope.$on 'status', (event, obj)->
    $scope.text = obj.text
    obj.promise.then -> delete $scope.text
