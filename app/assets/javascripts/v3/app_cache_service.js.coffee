angular.module('ledger').service 'appCache', ($window, $rootScope)->
  eventCallbacks = {}

  callback = (event)->
    for callback in eventCallbacks[event.type]
      $rootScope.$apply callback

  on: (event, callback)->
    $window.applicationCache.addEventListener(event, callback, false) unless eventCallbacks[event]
    (eventCallbacks[event] ||= []).push callback
    this
