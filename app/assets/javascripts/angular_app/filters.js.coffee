angular.module('Ledger').filter 'centsToDollars', ->
  (cents) ->
    cents / 100
