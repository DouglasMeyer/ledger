var AccountEditView = Backbone.View.extend({
  tagName: 'tr',
  template: _.template(JST['templates/account_edit']),
  events: {
    'blur .name input': 'updateName'
  },
  render: function(){
    var json = this.model.toJSON();
    json.balance = centsToCurrency(json.balance_cents);
    this.$el.append(this.template(json));
    this.update();
    return this;
  },
  update: function(){
    this.$('.name input').val(this.model.get('name'));
  },
  updateName: function(){
    this.model.set('name', this.$('.name input').val());
  }
});
