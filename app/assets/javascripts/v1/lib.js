var Model = Backbone.Model.extend({
  save: function(){
    if (this.get('_delete')){
      return this.destroy();
    } else {
      return Backbone.Model.prototype.save.apply(this, arguments);
    }
  }
});

var Collection = Backbone.Collection.extend({

  save: function(callback){
    var collection = this,
        saving = 0,
        onSuccess = function(account){
          saving -= 1;
          if (saving === 0){
            callback.call(collection);
          }
        };
    this.each(function(model){
      saving += 1;
      model.save(null, { success: onSuccess });
    });
  },

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
  }

});
