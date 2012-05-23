jQuery(function($){
  var table = $('#bank-entries');
  if (!table.length) return;

  var AccountEntryView = Backbone.View.extend({
    template: _.template($('#account-entry-template').html()),
    events: {
      'change input.account': 'updateAccount'
    },
    initialize: function(){
      this.model.bind('change', this.render, this);
      this.model.bind('destroy', this.remove, this);
    },
    render: function(){
      this.$el.html(this.template(this.model.toJSON()));
      this.$('input.account').val(this.model.get('accountName'));
      return this;
    },
    updateAccount: function(){
      this.model.set('accountName', this.$('input.account').val());
    }
  });
  var BankEntryView = Backbone.View.extend({
    className: 'bank-entry-view',
    template: _.template($('#bank-entry-template').html()),
    initialize: function(){
      this.model.bind('change', this.render, this);
      this.model.bind('destroy', this.remove, this);
    },
    render: function(){
      var json = this.model.toJSON(),
          ammount = (json.ammount+'.0').split('.');
      json.ammount = ammount[0] + '.' + (ammount[1] + '0').substr(0,2);
      this.$el.append(this.template(json));

      this.model.accountEntries.fetch();
      this.accountEntriesView = new AccountEntriesView({
        collection: this.model.accountEntries
      });
      this.$el.append(this.accountEntriesView.render().el);

      return this;
    }
  });
  window.BankEntries = new BankEntriesCollection();
  var BankEntriesView = Backbone.View.extend({
    initialize: function(){
      BankEntries.bind('add', this.addOne, this);
      BankEntries.bind('reset', this.addAll, this);
      BankEntries.bind('all', this.render, this);
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
