var AccountEntriesView = Backbone.View.extend({
  initialize: function(options){
    this.total = options.total;
    this.collection.bind('add', this.addOne, this);
    this.collection.bind('reset', this.addAll, this);
    this.collection.bind('all', this.render, this);
  },
  render: function(){
    this.collection.each(function(accountEntry){
      this.$el.append(new AccountEntryView({ model: accountEntry }));
    }, this);
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
