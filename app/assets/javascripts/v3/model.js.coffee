angular.module('ledger').factory 'Model', ($http, $filter, $timeout, $q)->
  strUnderscore = $filter('underscore')
  underscore = (cObj)->
    return cObj unless angular.isObject(cObj)

    uObj = {}
    for name, val of cObj when name.charAt(0) != '$' && name != 'className'
      newName = strUnderscore(name)
      if angular.isArray(val)
        uObj[newName] = ( underscore(v) for v in val )
      else if angular.isObject(val)
        uObj[newName] = underscore(val)
      else
        uObj[newName] = val
    uObj

  camelize = (uObj)->
    return uObj unless angular.isObject(uObj)

    cObj = {}
    for name, val of uObj
      newName = name.replace /_(\w)/g, (_,l)-> l.toUpperCase()
      if angular.isArray(val)
        cObj[newName] = ( camelize(v) for v in val )
      else if angular.isObject(val)
        cObj[newName] = camelize(val)
      else
        cObj[newName] = val
    cObj

  requestId = 0
  requests = []
  requestTimer = undefined
  deferreds = {}

  doRequest = (opts)->
    opts.reference = requestId++
    deferred = deferreds[opts.reference] = $q.defer()
    requests.push(opts)
    $timeout.cancel(requestTimer) if requestTimer
    requestTimer = $timeout(doRequestNow, 100)
    deferred.promise

  doRequestNow = ->
    requestTimer = undefined

    sentRequests = requests
    sentDeferreds = deferreds
    requests = []
    deferreds = {}

    $http
      .post('/api', JSON.stringify(sentRequests) )
      .then ({ data: { records, responses }})->
        for type, recordsById of records
          models[type].load(data for id, data of recordsById)
        for response in responses
          deferred = sentDeferreds[response.reference]
          records = for reference in response.records
            models[reference.type].get(reference.id)
          deferred.resolve(records)
      .catch (err)->
        deferred.reject(err) for _, deferred of sentDeferreds
      .finally ->
        sentRequests = sentDeferreds = undefined

  Model =
    init: ->
      @_allById ||= {}
      @all ||= []

    get: (id)->
      unless @_allById[id]?
        @_allById[id] = Object.create Model.Instance, @Instance
        @all.push(@_allById[id])

      @_allById[id]

    load: (datas)->
      for data in datas
        record = @get(data.id)
        record[k] = v for k, v of camelize(data)
        record

    unload: (record)->
      delete @_allById[record.id]
      index = @all.indexOf record
      @all.splice(index, 1) if index?

    read: (opts={})->
      opts.resource = @resource
      opts.action = 'read'
      doRequest(opts)

    save: (attrs, opts={})->
      opts.resource = @resource
      opts.action = if attrs.id? then 'update' else 'create'
      opts.id = attrs.id
      opts.data = attrs
      doRequest(opts)

    destroy: (attrs, opts={})->
      opts.resource = @resource
      opts.action = 'delete'
      opts.id = attrs.id
      opts.data = attrs
      doRequest(opts)

    Instance: {}

  models =
    Account: Object.create Model,
      name: value: 'Account'
      resource: value: 'Account_v1'

      Instance: value:
        isDeleted:
          get: ->
            !!(if @deletedAt == null then @_destroy else @deletedAt)
          set: (val)->
            if val
              @_destroy = true
            else
              delete @_destroy
              @deletedAt = null

    BankEntry: Object.create Model,
      name: value: 'BankEntry'
      resource: value: 'BankEntry_v1'

      save: value: (camelcaseAttrs, opts={})->
        attrs = underscore(camelcaseAttrs)
        delete attrs.balance_cents
        attrs.account_entries_attributes = attrs.account_entries
        delete attrs.account_entries

        Model.save.call(this, attrs, opts)

    AccountEntry: Object.create Model,
      name: value: 'AccountEntry'

    ProjectedEntry: Object.create Model,
      name: value: 'ProjectedEntry'
      resource: value: 'ProjectedEntry_v1'

  models.Account.init()
  models.BankEntry.init()
  models.AccountEntry.init()
  models.ProjectedEntry.init()
  models
