angular.module('ledger').controller 'CalculatorCtrl', ($scope, Model, $filter, $parse)->
  underscore = $filter('underscore')

  calcScope = {}
  $scope.accounts = Model.Account.all
  $scope.$watchCollection 'accounts', (all)->
    calcScope = {}
    return unless all
    calcScope[underscore(account.name)] = account.balanceCents / 100 for account in all

  $scope.toggle = ->
    $scope.showCalc = !$scope.showCalc
    $scope.input = ''

  $scope.$watch 'input', (input)->
    try
      $scope.output = if input
        $parse(input)(calcScope) * 100
      else
        ''
      $scope.form.input.$setValidity('parses', true)
    catch
      $scope.form.input.$setValidity('parses', false)
