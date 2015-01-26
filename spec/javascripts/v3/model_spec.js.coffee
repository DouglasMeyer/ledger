#= require v3
#= require angular-mocks/angular-mocks

describe "Model", ->
  beforeEach module 'ledger'
  beforeEach inject (@Model)-> null

  describe 'ProjectedEntry', ->
    it 'updates the rrule when setting date', ->
      pEntry = @Model.ProjectedEntry.new()
      date = new Date(Date.now() + 1000*60*60*24*7)

      pEntry.date = date

      expect(pEntry.rrule).toEqual(new RRule(
        dtstart: date
      ).toString())

    it 'updates the rrule when setting until', ->
      pEntry = @Model.ProjectedEntry.new()
      date = new Date(Date.now() + 1000*60*60*24*7)

      pEntry.until = date

      expect(pEntry.rrule).toEqual(new RRule(
        until: date
      ).toString())
