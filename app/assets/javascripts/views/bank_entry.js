var BankEntryView = Backbone.View.extend({
  className: 'bank-entry-view',
  template: _.template(JST['templates/bank_entry']),
  initialize: function(){
    this.model.bind('change', this.render, this);
    var accountEntries = this.model.accountEntries;
    accountEntries.bind('all', this.updateAmmountRemaining, this);
    accountEntries.loading = true;
    accountEntries.fetch({
      success: function(){
        delete accountEntries.loading;
        accountEntries.trigger('fetch');
      }
    });
  },
  remove: function(){
    this.model.unbind(null, null, this);
    this.model.accountEntries.unbind(null, null, this);
    this.constructor.__super__.remove.apply(this, arguments);
  },
  events: {
    'focus .ammount-remaining input': 'addAccountEntry'
  },
  render: function(){
    var json = this.model.toJSON();
    json.ammount = centsToCurrency(json.ammount_cents);
    this.$el.html(this.template(json));

    this.accountEntriesView = new AccountEntriesView({
      collection: this.model.accountEntries
    });
    this.$el.append(this.accountEntriesView.render().el);

    this.$el.append('<div class="row ammount-remaining"><a href="#bank_entries/'+this.model.get('id')+'" rel="distribute-to-accounts">Distribute to accounts</a><input class="ammount currency" /></div>');
    this.updateAmmountRemaining();

    return this;
  },
  addAccountEntry: function(){
    var difference = this.model.accountEntryAmmountCentsDifference();
    this.model.accountEntries.add({
      bank_entry_id: this.model.get('id'),
      ammount_cents: difference
    });
    this.$('.row.account-entry input.ammount:last').focus();
  },
  updateAmmountRemaining: function(){
    var difference = this.model.accountEntryAmmountCentsDifference();
    var loading = this.model.accountEntries.loading;
    this.$('.row.ammount-remaining .ammount').val(centsToCurrency(difference));
    this.$('.row.ammount-remaining')[loading || difference === 0 ? 'hide' : 'show']();
    this.$el[loading || difference === 0 ? 'removeClass' : 'addClass']('hasAmmountRemaining');
  }
});
