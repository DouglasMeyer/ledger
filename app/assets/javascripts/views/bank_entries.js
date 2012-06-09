var BankEntriesView = Backbone.View.extend({
  initialize: function(){
    BankEntries.bind('add', this.addOne, this);
    BankEntries.bind('reset', this.addAll, this);
    BankEntries.bind('all', this.render, this);
    Accounts.fetch();
    BankEntries.fetch();
  },
  render: function(){},
  addOne: function(bankEntry){
    var view = new BankEntryView({ model: bankEntry });
    this.$el.append(view.render().el);
  },
  addAll: function(){
    BankEntries.each(this.addOne, this);
  }
});
