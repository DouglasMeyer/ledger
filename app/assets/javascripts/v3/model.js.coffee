angular.module('ledger').factory 'Model', ($http, $filter, $window)->
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

  Model =
    get: (id)->
      @_all ||= {}
      @_all[id] ||= {}

    load: (datas)->
      for data in datas
        record = @get(data.id)
        record[k] = v for k, v of camelize(data)
        record

    handleResponse: (response)->
      for type, recordsById of response.data.records
        models[type].load(data for id, data of recordsById)
      for reference in response.data.responses[0].records
        models[reference.type].get(reference.id)

    read: (opts={})->
      opts.resource = @resource
      opts.action = 'read'
      $http
        .post('/api', JSON.stringify([ opts ]) )
        .then(@handleResponse)

    save: (attrs, opts={})->
      opts.resource = @resource
      opts.action = if attrs.id? then 'update' else 'create'
      opts.id = attrs.id
      opts.data = attrs
      $http
        .post('/api', JSON.stringify([ opts ]) )
        .then(@handleResponse)

  Object.defineProperty Model, 'all',
    get: ->
      return @_getAll if @_getAll?
      @read().then (all)=>
        $window.localStorage.setItem("Model.#{@name}.all", angular.toJson(all))
        @_getAll.splice(0,@_getAll.length, all...)
      try
        @_getAll = @load(angular.fromJson($window.localStorage.getItem("Model.#{@name}.all")))
      @_getAll ||= (record for id, record of @_all)
    enumerable: true
    configurable: false

  models =
    Account: Object.create Model,
      name: value: 'Account'
      resource: value: 'Account_v1'

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
