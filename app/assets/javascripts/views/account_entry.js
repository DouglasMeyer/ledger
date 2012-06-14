var AccountEntryView = Backbone.View.extend({
  template: _.template(JST['templates/account_entry']),
  events: {
    'focus input': 'focusInput',
    'blur input.ammount': 'updateAmmount',
    'blur input.account': 'updateAccount',
    'click [rel="remove-account-entry"]': 'removeAccountEntry'
  },
  initialize: function(){
    this.model.bind('change', this.update, this);
    this.model.bind('destroy', this.remove, this);
  },
  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    this.$('input.account').autocomplete({
      source: app.Accounts.pluck('name'),
      autoFocus: true
    });
    this.update();
    return this;
  },
  update: function(){
    this.$('input.ammount').val(centsToCurrency(this.model.get('ammount_cents')));
    this.$('input.account').val(this.model.get('account_name'));
  },
  focusInput: function(event){
    setTimeout(function(){ event.target.select(); });
  },
  updateAmmount: function(){
    this.model.set('ammount_cents', currencyToCents(this.$('input.ammount').val()));
    this.isFilledOut() && this.saveAccountEntry();
    this.isBlank() && this.removeAccountEntry();
  },
  updateAccount: function(){
    this.model.set('account_name', this.$('input.account').val());
    this.isFilledOut() && this.saveAccountEntry();
    this.isBlank() && this.removeAccountEntry();
  },
  isBlank: function(){
    return !this.model.get('ammount_cents') && !this.model.get('account_name');
  },
  isFilledOut: function(){
    return this.model.get('ammount_cents') && this.model.get('account_name');
  },
  saveAccountEntry: function(){
    this.model.save();
  },
  removeAccountEntry: function(){
    this.model.destroy();
  }
});
