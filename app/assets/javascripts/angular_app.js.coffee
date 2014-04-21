#= require angular
#= require angular-route
#= require angular-animate
#= require jquery
#= require_self
#= require_tree ./angular_app

window.Ledger = angular.module('Ledger', ['LedgerServices', 'ngRoute', 'ngAnimate'])
  .config ($routeProvider) ->
    $routeProvider.when '/accounts', templateUrl: 'angular/accounts.html', controller: 'AccountsController'
    $routeProvider.when '/account/:id', templateUrl: 'angular/account.html', controller: 'AccountController'
    $routeProvider.when '/entries', templateUrl: 'angular/entries.html', controller: 'EntriesController'
    $routeProvider.when '/entries/:id', templateUrl: 'angular/entry.html', controller: 'EntryController'
    $routeProvider.otherwise redirectTo: '/accounts'
