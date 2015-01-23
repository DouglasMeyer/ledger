#= require v3
#= require angular-mocks/angular-mocks

describe "ForecastCtrl", ->
  beforeEach module 'ledger'
  beforeEach inject (@$controller, @$rootScope, @Model)-> null

  it 'creates forecastedEntries from projectedEntries', ->
    scope = @$rootScope.$new()
    @Model.ProjectedEntry.all = [
      rule: new RRule
        freq: RRule.MONTHLY
    ]
    controller = @$controller('ForecastCtrl', $scope: scope)
    scope.$digest()

    expect(scope.forecastedEntries.length).toEqual 3
    now = new Date()
    nextMonth = new Date()
    nextMonth.setMonth now.getMonth()+1
    nextNextMonth = new Date()
    nextNextMonth.setMonth now.getMonth()+2
    expected = [
      date: now
      projectedEntry: @Model.ProjectedEntry.all[0]
      isFirst: true
    ,
      date: nextMonth
      projectedEntry: @Model.ProjectedEntry.all[0]
      isFirst: false
    ,
      date: nextNextMonth
      projectedEntry: @Model.ProjectedEntry.all[0]
      isFirst: false
    ]
    for forecastedEntry, index in scope.forecastedEntries
      expect(forecastedEntry.date.toDateString()).toEqual expected[index].date.toDateString()
      expect(forecastedEntry.projectedEntry).toBe expected[index].projectedEntry
      expect(forecastedEntry.isFirst).toBe expected[index].isFirst

  it 'creates forecastedEntries for new projectedEntries', ->
    scope = @$rootScope.$new()
    controller = @$controller('ForecastCtrl', $scope: scope)
    scope.$digest()
    scope.$root.pageActions[0].click()
    scope.$digest()

    expect(scope.forecastedEntries.length).toEqual 1
    scope.forecastedEntries[0].frequency = 'Weekly'
    scope.saveEdit scope.forecastedEntries[0]

    expect(scope.projectedEntries.length).toEqual 1
    rrule = new RRule( freq: RRule.WEEKLY )
    weekCount = rrule.between(new Date(Date.now()-1000*60), new Date(Date.now()+1000*60*60*24*30*2.5)).length
    expect(scope.forecastedEntries.length).toEqual weekCount
