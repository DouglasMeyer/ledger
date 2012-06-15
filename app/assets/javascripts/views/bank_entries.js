var BankEntriesView = Backbone.View.extend({
  className: 'bank-entries',
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
