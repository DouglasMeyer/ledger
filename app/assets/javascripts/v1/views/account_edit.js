var AccountEditView = Backbone.View.extend({
  tagName: 'tr',
  template: _.template(JST['v1/templates/account_edit']),
  events: {
    'blur .name input': 'updateName',
    'click .delete': 'delete'
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
  },
  delete: function(){
    if (this.model.get('balance_cents') === 0){
      this.model.set('_delete', !this.model.get('_delete'));
      this.$el.toggleClass('deleted', this.model.get('_delete'));
      this.$('input').attr({ disabled: this.model.get('_delete') });
    } else {
      alert('The account needs to have a $0 balance.');
    }
  }
});
