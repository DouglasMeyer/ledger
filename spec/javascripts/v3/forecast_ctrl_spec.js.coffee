#= require v3
#= require angular-mocks/angular-mocks

describe "ForecastCtrl", ->
  beforeEach module 'ledger'
  beforeEach inject (@$controller, @$rootScope, @Model, $q)->
    @$q = $q
    @deferredSave = $q.defer()
    spyOn(@Model.ProjectedEntry, 'save').andCallFake => @deferredSave.promise


  it 'creates forecastedEntries from projectedEntries', ->
    scope = @$rootScope.$new()
    pEntry = @Model.ProjectedEntry.new()
    pEntry.rrule = new RRule(
      freq: RRule.MONTHLY
    ).toString()
    @Model.ProjectedEntry.all = [ pEntry ]
    controller = @$controller('ForecastCtrl', $scope: scope)
    scope.$digest()

    expect(scope.forecastedEntries.length).toEqual 3
    now = new Date()
    nextMonth = new Date()
    nextMonth.setMonth now.getMonth()+1
    nextNextMonth = new Date()
    nextNextMonth.setMonth now.getMonth()+2
    projectedEntry = @Model.ProjectedEntry.all[0]

    forecastedEntry = scope.forecastedEntries[0]
    expect(forecastedEntry.date.toDateString()).toEqual now.toDateString()
    expect(forecastedEntry.projectedEntry).toBe projectedEntry
    expect(forecastedEntry.isFirst).toBe true

    forecastedEntry = scope.forecastedEntries[1]
    expect(forecastedEntry.date.toDateString()).toEqual nextMonth.toDateString()
    expect(forecastedEntry.projectedEntry).toBe projectedEntry
    expect(forecastedEntry.isFirst).toBe false

    forecastedEntry = scope.forecastedEntries[2]
    expect(forecastedEntry.date.toDateString()).toEqual nextNextMonth.toDateString()
    expect(forecastedEntry.projectedEntry).toBe projectedEntry
    expect(forecastedEntry.isFirst).toBe false

  it 'shows projected entries that ended in the past', ->
    scope = @$rootScope.$new()
    day = 1000*3600*24
    pEntry = @Model.ProjectedEntry.new()
    pEntry.rrule = new RRule(
      dtstart: new Date(Date.now() - day * 10)
      freq: RRule.DAILY
      until: new Date(Date.now() - day * 5)
    ).toString()
    @Model.ProjectedEntry.all = [ pEntry ]

    controller = @$controller('ForecastCtrl', $scope: scope)
    scope.$digest()

    expect(scope.forecastedEntries.length).toEqual 1

  it 'creates forecastedEntries for new projectedEntries', ->
    scope = @$rootScope.$new()
    controller = @$controller('ForecastCtrl', $scope: scope)
    scope.$digest()
    scope.$root.pageActions[0].click()
    scope.$digest()

    expect(scope.forecastedEntries.length).toEqual 1
    scope.forecastedEntries[0].frequency = 'Weekly'
    scope.saveEdit scope.forecastedEntries[0]
    @deferredSave.resolve scope.projectedEntries
    scope.$digest()

    expect(scope.projectedEntries.length).toEqual 1
    rrule = new RRule( freq: RRule.WEEKLY )
    weekCount = rrule.between(
      new Date(Date.now()-1000*60),
      new Date(Date.now()+1000*60*60*24*30*2.5)
    ).length
    expect(scope.forecastedEntries.length).toEqual weekCount

  it 'persists on save', ->
    scope = @$rootScope.$new()
    controller = @$controller('ForecastCtrl', $scope: scope)
    scope.$digest()
    scope.$root.pageActions[0].click()
    scope.$digest()

    scope.saveEdit scope.forecastedEntries[0]
    latestCallArgs = @Model.ProjectedEntry.save.mostRecentCall.args
    expect(latestCallArgs[0].rrule).toEqual new RRule(
      freq: RRule.DAILY
      count: 1
      dtstart: new Date
    ).toString()
