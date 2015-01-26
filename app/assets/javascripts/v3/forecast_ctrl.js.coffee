angular.module('ledger').controller 'ForecastCtrl', ($scope, Model)->

  arrayRemove = (array, item)->
    index = array.indexOf item
    array.splice index, 1 unless index == -1

  $scope.$root.pageActions = [ {
    text: 'Add Projection'
    icon: 'plus'
    click: ->
      newEntry = Model.ProjectedEntry.new()
      newEntry.rrule = new RRule(
        freq: RRule.DAILY
        count: 1
        dtstart: new Date
      ).toString()
      $scope.projectedEntries.unshift newEntry
  } ]

  $scope.accounts = Model.Account.all
  $scope.$watchCollection 'accounts | filter:{isDeleted:false} | pMap:"name" | orderBy', (accountNames)->
    $scope.accountNames = accountNames

  $scope.projectedEntries = Model.ProjectedEntry.all
  $scope.forecastedEntries = []

  day = 24 * 60 * 60 * 1000
  $scope.today = new Date
  $scope.today.setHours(0)
  $scope.today.setMinutes(0)
  $scope.today.setSeconds(0)
  endDate = new Date($scope.today.getTime() + 2.5 * 30 * day)

  createForecastedEntry = (attrs)->
    Object.defineProperties(attrs, {
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

  createForecastedEntries = (pEntry)->
    $scope.forecastedEntries = $scope.forecastedEntries.filter (forecatedEntry)->
      forecatedEntry.projectedEntry != pEntry

    dates = pEntry.rule.between($scope.today, endDate)
    if dates.length == 0
      all = pEntry.rule.all()
      dates.push all[all.length-1]

    for date, index in dates
      forecastedEntry = createForecastedEntry
        date: date
        projectedEntry: pEntry
        isFirst: index == 0
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

  $scope.startEdit = (fEntry)->
    return if fEntry.isEditing || !fEntry.isFirst
    fEntry.isEditing = true
    if fEntry.projectedEntry.id
      fEntry.stashedProjectedEntry = angular.copy fEntry.projectedEntry

  $scope.cancelEdit = (fEntry, e)->
    e.stopPropagation()
    delete fEntry.isEditing
    if fEntry.stashedProjectedEntry
      angular.copy fEntry.stashedProjectedEntry, fEntry.projectedEntry
      delete fEntry.stashedProjectedEntry
    else
      arrayRemove $scope.projectedEntries, fEntry.projectedEntry

  $scope.saveEdit = (fEntry)->
    delete fEntry.isEditing
    fEntry.saving = true
    promise = Model.ProjectedEntry.save(fEntry.projectedEntry).then (projectedEntries)->
      if fEntry.projectedEntry != projectedEntries[0] # you just created a ProjectedEntry
        arrayRemove $scope.projectedEntries, fEntry.projectedEntry
      else
        delete fEntry.saving
        createForecastedEntries(fEntry.projectedEntry)
    $scope.$root.$emit 'status',
      text: 'saving'
      promise: promise

  $scope.deleteEntry = (fEntry)->
    promise = Model.ProjectedEntry.destroy(fEntry.projectedEntry).then ->
      arrayRemove $scope.projectedEntries, fEntry.projectedEntry
