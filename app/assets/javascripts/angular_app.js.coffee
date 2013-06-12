#= require angular
#= require jquery
#= require_self
#= require_tree ./angular_app

window.Ledger = angular.module('Ledger', ['LedgerServices'])
  .config(['$routeProvider', ($routeProvider) ->
    $routeProvider.when '/accounts', templateUrl: 'angular/accounts.html', controller: 'AccountsController'
    $routeProvider.when '/account/:id', templateUrl: 'angular/account.html', controller: 'AccountController'
    $routeProvider.when '/entries', templateUrl: 'angular/entries.html', controller: 'EntriesController'
    $routeProvider.otherwise redirectTo: '/accounts'
  ])
