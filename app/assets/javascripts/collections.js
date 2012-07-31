var BankEntriesCollection = Backbone.Collection.extend({
  model: BankEntry,
  url: '/bank_entries',
  fetch: function(options){
    options = options ? _.clone(options) : {};
    if (options.parse === undefined) options.parse = true;
    var collection = this;
    var success = options.success;
    options.success = function(resp, status, xhr) {
      collection.more = xhr.getResponseHeader('X-More');
      collection[options.add ? 'add' : 'reset'](collection.parse(resp, xhr), options);
      if (success) success(collection, resp);
    };
    options.error = Backbone.wrapError(options.error, collection, options);
    return (this.sync || Backbone.sync).call(this, 'read', this, options);
  },
  loadMore: function(options){
    options.url = this.more;
    options.add = true;
    this.fetch(options);
  }
});

var AccountsCollection = Backbone.Collection.extend({
  model: Account,
  url: '/accounts',

  assets:      function(){ return this.filter(function(a){ return  a.get('asset'); }); },
  liabilities: function(){ return this.filter(function(a){ return !a.get('asset'); }); },

  save: function(callback){
    var collection = this,
        saving = 0,
        onSuccess = function(account){
          saving -= 1;
          if (saving === 0){
            callback.call(collection);
          }
        };
    this.each(function(account){
      saving += 1;
      account.save(null, { success: onSuccess });
    });
  }
});

var AccountEntriesCollection = Backbone.Collection.extend({
  model: AccountEntry,
  url: '/account_entries'
});

