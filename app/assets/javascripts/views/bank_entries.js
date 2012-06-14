var BankEntriesView = Backbone.View.extend({
  className: 'bank-entries',
  initialize: function(){
    app.BankEntries.bind('add', this.addOne, this);
    app.BankEntries.bind('reset', this.addAll, this);
    app.BankEntries.bind('all', this.render, this);
  },
  render: function(){
    this.addAll();
    return this;
  },
  addOne: function(bankEntry){
    var view = new BankEntryView({ model: bankEntry });
    this.$el.append(view.render().el);
  },
  addAll: function(){
    app.BankEntries.each(this.addOne, this);
  }
});
