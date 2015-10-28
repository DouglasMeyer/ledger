angular.module('ledger').service 'appCache', ($window, $rootScope)->
  eventCallbacks = {}

  callback = (event)->
    for callback in eventCallbacks[event.type]
      $rootScope.$apply callback

  on: (event, callback)->
    unless eventCallbacks[event]
      $window.applicationCache.addEventListener(event, callback, false)
    (eventCallbacks[event] ||= []).push callback
    this
