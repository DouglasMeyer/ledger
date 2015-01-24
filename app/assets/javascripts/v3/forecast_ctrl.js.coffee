angular.module('ledger').controller 'ForecastCtrl', ($scope, Model)->

  $scope.$root.pageActions = [ {
    text: 'Add Projection'
    icon: 'plus'
    click: ->
      newEntry = Object.create {}, Model.ProjectedEntry.Instance
      newEntry.rrule = new RRule(
        freq: RRule.DAILY
        count: 1
      ).toString()
      $scope.projectedEntries.unshift newEntry
  } ]

  $scope.projectedEntries = Model.ProjectedEntry.all
  $scope.forecastedEntries = []

  day = 24 * 60 * 60 * 1000
  startDate = new Date(parseInt(Date.now() / day) * day)
  endDate = new Date(startDate.getTime() + 2.5 * 30 * day)

  createForecastedEntries = (pEntry)->
    $scope.forecastedEntries = $scope.forecastedEntries.filter (forecatedEntry)->
      forecatedEntry.projectedEntry != pEntry

    for date, index in pEntry.rule.between(startDate, endDate)
      forecastedEntry = Object.defineProperties({
        date: date
        projectedEntry: pEntry
        isFirst: index == 0
      }, {
        frequency:
          get: ->
            return @_frequency if @_frequency
            rule = @projectedEntry.rule.options
            for label, freq of $scope.frequencyOptions
              if rule.freq == freq.freq && rule.interval == (freq.interval || 1)
                @_frequency = label
            @_frequency

          set: (val)->
            @_frequency = val
            freq = $scope.frequencyOptions[val]
            @projectedEntry.rule.origOptions.freq = freq.freq
            @projectedEntry.rule.origOptions.interval = freq.interval
            @projectedEntry.rule.origOptions.count = freq.count
            @projectedEntry.rrule = @projectedEntry.rule.toString()
      })
      $scope.startEdit(forecastedEntry) unless pEntry.id
      $scope.forecastedEntries.push forecastedEntry

  $scope.$watchCollection 'projectedEntries', (newPEntries, oldPEntries)->
    for pEntry in oldPEntries
      unless pEntry in newPEntries
        $scope.forecastedEntries = $scope.forecastedEntries.filter (forecatedEntry)->
          forecatedEntry.projectedEntry != pEntry

    for projectedEntry in newPEntries
      if newPEntries == oldPEntries || projectedEntry not in oldPEntries
        createForecastedEntries(projectedEntry)

  $scope.frequencyOptions =
    'Once':
      freq: RRule.DAILY
      interval: 1
      count: 1
    'Weekly':
      freq: RRule.WEEKLY
      interval: 1
      count: null
    'Monthly':
      freq: RRule.MONTHLY
      interval: 1
      count: null
    'every 6 Months':
      freq: RRule.MONTHLY
      interval: 6
      count: null

  $scope.startEdit = (entry)->
    return if entry.isEditing
    entry.isEditing = true
    if entry.projectedEntry.id
      entry.stashedProjectedEntry = angular.copy entry.projectedEntry

  $scope.cancelEdit = (entry)->
    delete entry.isEditing
    if entry.stashedProjectedEntry
      angular.copy entry.stashedProjectedEntry, entry.projectedEntry
      delete entry.stashedProjectedEntry
    else
      index = $scope.projectedEntries.indexOf entry.projectedEntry
      $scope.projectedEntries.splice index, 1

  $scope.saveEdit = (entry)->
    delete entry.isEditing
    entry.projectedEntry.id = new Date
    createForecastedEntries(entry.projectedEntry)
