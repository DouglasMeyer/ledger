jQuery(function($){
  var table = $('#bank-entries');
  if (!table.length) return;

  var centsToCurrency = function(cents){
    var string = (cents + '').split(''),
        cents = [],
        negative = string[0] === '-';
    if (negative) { string.shift(); }
    cents.unshift(string.pop() || '0');
    cents.unshift(string.pop() || '0');
    return (negative ? '-' : '') + (string.join('') || '0') + '.' + cents.join('');
  };
  var currencyToCents = function(currency){
    return currency ? Math.round(parseFloat(currency) * 100) : 0;
  };

  var AccountEntryView = Backbone.View.extend({
    template: _.template($('#account-entry-template').html()),
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
        source: Accounts.pluck('name'),
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
  var BankEntryView = Backbone.View.extend({
    className: 'bank-entry-view',
    template: _.template($('#bank-entry-template').html()),
    initialize: function(){
      this.model.bind('change', this.render, this);
      this.model.bind('destroy', this.remove, this);
      this.model.accountEntries.bind('all', this.updateAmmountRemaining, this);
    },
    events: {
      'focus .ammount-remaining input': 'addAccountEntry'
    },
    render: function(){
      var json = this.model.toJSON();
      json.ammount = centsToCurrency(json.ammount_cents);
      this.$el.append(this.template(json));

      this.model.accountEntries.fetch();
      this.accountEntriesView = new AccountEntriesView({
        collection: this.model.accountEntries
      });
      this.$el.append(this.accountEntriesView.render().el);

      this.$el.append('<div class="row ammount-remaining"><input class="ammount currency" /></div>');
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
      this.$('.row.ammount-remaining .ammount').val(centsToCurrency(difference));
      this.$('.row.ammount-remaining')[difference === 0 ? 'hide' : 'show']();
    }
  });
  window.BankEntries = new BankEntriesCollection();
  window.Accounts = new AccountsCollection();
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

  table.find('.row.bank_entry').remove();
  window.bankEntries = new BankEntriesView({ el: table });
});
