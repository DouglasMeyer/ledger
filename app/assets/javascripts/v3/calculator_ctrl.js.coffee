angular.module('ledger').controller 'CalculatorCtrl', ($scope, Model, $filter, $parse)->
  underscore = $filter('underscore')

  calcScope = {}
  $scope.accounts = Model.Account.all
  $scope.$watch 'accounts | map:"balanceCents" | join', ->
    calcScope = {}
    return unless $scope.accounts
    calcScope[underscore(account.name)] = account.balanceCents / 100 for account in $scope.accounts

  $scope.toggle = ->
    $scope.showCalc = !$scope.showCalc
    $scope.input = ''

  unWatchExp = undefined
  $scope.$watch 'input', (input)->
    unWatchExp() if unWatchExp?
    unWatchExp = undefined
    try
      parsedInput = $parse(input)
      output = parsedInput(calcScope) * 100
      if isNaN(output)
        throw 'something'
      else
        unWatchExp = $scope.$watch ->
          $scope.output = parsedInput(calcScope) * 100
      $scope.form.input.$setValidity('parses', true)
    catch
      $scope.form.input.$setValidity('parses', false)
