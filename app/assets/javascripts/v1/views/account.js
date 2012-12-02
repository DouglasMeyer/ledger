var AccountView = Backbone.View.extend({
  tagName: 'tr',
  template: _.template(JST['v1/templates/account']),
  render: function(){
    var json = this.model.toJSON();
    json.balance = centsToCurrency(json.balance_cents);
    this.$el.append(this.template(json));
    return this;
  }
});
