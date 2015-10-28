#= require v3
#= require angular-mocks/angular-mocks

describe "ForecastCtrl", ->
  beforeEach module 'ledger'
  beforeEach inject (@$controller, @$rootScope, @Model, @$q)->
    @deferredSave = @$q.defer()
    spyOn(@Model.ProjectedEntry, 'save').and.callFake => @deferredSave.promise


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
    projectedEntry = @Model.ProjectedEntry.all[0]

    date = new Date()
    forecastedEntry = scope.forecastedEntries[0]
    expect(forecastedEntry.date.toDateString()).toEqual date.toDateString()
    expect(forecastedEntry.projectedEntry).toBe projectedEntry
    expect(forecastedEntry.isFirst).toBe true

    date.setMonth date.getMonth()+1
    forecastedEntry = scope.forecastedEntries[1]
    expect(forecastedEntry.date.toDateString()).toEqual date.toDateString()
    expect(forecastedEntry.projectedEntry).toBe projectedEntry
    expect(forecastedEntry.isFirst).toBe false

    date.setMonth date.getMonth()+1
    forecastedEntry = scope.forecastedEntries[2]
    expect(forecastedEntry.date.toDateString()).toEqual date.toDateString()
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
    latestCallArgs = @Model.ProjectedEntry.save.calls.mostRecent().args
    expect(latestCallArgs[0].rrule).toEqual new RRule(
      freq: RRule.DAILY
      count: 1
      dtstart: new Date
    ).toString()
