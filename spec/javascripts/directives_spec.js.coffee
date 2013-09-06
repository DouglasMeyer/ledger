#= require angular_app/directives

describe 'lCurrency', ->
  $scope = element = undefined

  beforeEach module('Ledger')

  describe 'for non-input', ->
    beforeEach inject ($compile, $rootScope) ->
      $scope = $rootScope
      element = angular.element """
        <span l-currency ng-model="model.cents"></span>
      """
      $compile(element)($scope)

    it "renders a formatted value", ->
      $scope.model =
        cents: -123456
      $scope.$digest()
      expect(element.text()).toBe '$-1,234.56'

  describe 'for input', ->
    beforeEach inject ($compile, $rootScope) ->
      $scope = $rootScope
      element = angular.element """
        <form name="theForm">
          <input name="theInput" l-currency ng-model="model.cents" />
        </form>
      """
      $compile(element)($scope)

    it "formats the value", ->
      $scope.model =
        cents: -123456
      $scope.$digest()
      expect($scope.theForm.theInput.$viewValue).toBe '$-1,234.56'

    it "parses the input", ->
      $scope.model =
        cents: 33344
      $scope.theForm.theInput.$setViewValue '555.66'
      $scope.$digest()
      expect($scope.model.cents).toEqual 55566
