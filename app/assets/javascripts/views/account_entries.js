var AccountEntriesView = Backbone.View.extend({
  initialize: function(options){
    this.total = options.total;
    this.collection.bind('add', this.addOne, this);
    this.collection.bind('reset', this.addAll, this);
  },
  remove: function(){
    this.collection.unbind(null, null, this);
    this.constructor.__super__.remove.apply(this, arguments);
  },
  render: function(){
    this.addAll();
    return this;
  },
  addOne: function(accountEntry){
    var view = new AccountEntryView({ model: accountEntry });
    this.$el.append(view.render().el);
  },
  addAll: function(){
    this.collection.each(this.addOne, this);
  }
});
