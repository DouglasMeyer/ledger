#= require angular_app/directives

describe 'lCurrency', ->
  element = undefined

  beforeEach module('Ledger')

  describe 'for non-input', ->
    beforeEach inject ($compile, $rootScope) ->
      element = $compile("""
        <span l-currency ng-model="model.cents"></span>
      """)($rootScope)

    it "renders a formatted value", inject ($rootScope) ->
      $rootScope.model =
        cents: -123456
      $rootScope.$digest()
      expect(element.text()).toBe '$-1,234.56'

  describe 'for input', ->
    beforeEach inject ($compile, $rootScope) ->
      element = $compile("""
        <input l-currency ng-model="model.cents" />
      """)($rootScope)

    it "formats the value", inject ($rootScope) ->
      $rootScope.model =
        cents: -123456
      $rootScope.$digest()
      expect(element.val()).toBe '$-1,234.56'
