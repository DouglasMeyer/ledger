#= require angular_app/controllers

describe 'AccountsController', ->
  scope = undefined
  controller = undefined

  beforeEach module('Ledger')

  beforeEach inject ($rootScope, $controller) ->
    mockAPIRequest.reset()

    scope = $rootScope.$new()
    controller = $controller 'AccountsController',
      $scope: scope
      APIRequest: mockAPIRequest

  it 'sets $scope.groups', ->
    thing2    = { position: 2, asset: true,  category: 'Thing', name: 'thing 2' }
    thing     = { position: 1, asset: false, category: 'Thing', name: 'thing' }
    thing1    = { position: 1, asset: true,  category: 'Thing', name: 'thing 1' }
    something = { position: 2, asset: false, category: 'Other Thing', name: 'something' }
    request = mockAPIRequest.requests[0]
    mockAPIRequest.satisfyRequest request, [ thing2, thing, thing1, something ]

    expect(scope.groups).toEqual {
      Assets: [ thing1, thing2 ]
      Liabilities: [ thing, something ]
    }
