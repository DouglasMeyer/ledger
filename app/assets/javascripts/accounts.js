jQuery(function($){
  var el = $('.accounts.distribute');
  if (!el.length) return;

  window.Accounts = new AccountsCollection();
  window.AccountEntries = new AccountEntriesCollection();

  var AccountView = Backbone.View.extend({
    tagName: 'tr',
    template: _.template($('#account-template').html()),
    events: {
      'blur input.ammount': 'updateAmmount'
    },
    initialize: function(){
      this.model.bind('change', this.update, this);
      this.model.bind('destroy', this.remove, this);
      this.accountEntry = new AccountEntry({
        account_name: this.model.get('name'),
        ammount_cents: 0
      });
      AccountEntries.add(this.accountEntry);
      this.accountEntry.bind('change', this.update, this);
    },
    render: function(){
      var json = this.model.toJSON();
      json.balance = centsToCurrency(json.balance_cents);
      this.$el.html(this.template(json));
      this.update();
      return this;
    },
    update: function(){
      this.$('input.ammount').val(centsToCurrency(this.accountEntry.get('ammount_cents')));
      this.$('td.balance').html(centsToCurrency(
        this.model.get('balance_cents') +
        this.accountEntry.get('ammount_cents')
      ));
    },
    updateAmmount: function(){
      this.accountEntry.set('ammount_cents', currencyToCents(this.$('input.ammount').val()));
    }
  });
  var AccountsView = Backbone.View.extend({
    tagName: 'table',
    initialize: function(){
      Accounts.bind('add', this.addOne, this);
      Accounts.bind('reset', this.addAll, this);
    },
    render: function(){
      this.$el.html('<caption>'+this.title+'</caption>');
      return this;
    },
    addAll: function(){
      var accounts = Accounts[this.asset ? 'assets' : 'liabilities']();
      _.each(accounts, this.addOne, this);
    },
    addOne: function(account){
      var view = new AccountView({ model: account });
      this.$el.append(view.render().el);
    }
  });
  var AssetsView      = AccountsView.extend({ title: 'Assets',      className: 'assets',      asset: true });
  var LiabilitiesView = AccountsView.extend({ title: 'Liabilities', className: 'liabilities'              });
  var DistributeAccountView = Backbone.View.extend({
    initialize: function(){
      AccountEntries.bind('add', this.updateDistributeAmmount, this);
      AccountEntries.bind('reset', this.updateDistributeAmmount, this);
      AccountEntries.bind('all', this.updateDistributeAmmount, this);
      this.render();
      Accounts.fetch();
    },
    render: function(){
      var assets = new AssetsView(),
          liabilities = new LiabilitiesView();
      this.$el.append(assets.render().el);
      this.$el.append(liabilities.render().el);
      return this;
    },
    updateDistributeAmmount: function(){
      var ammountCents = Accounts.get(window.accountId).get('balance_cents');
      AccountEntries.each(function(ae){
        ammountCents -= ae.get('ammount_cents');
      });
      $('.distribute-ammount').html(centsToCurrency(ammountCents));
    }
  });

  el.empty();
  window.distributeAccount = new DistributeAccountView({ el: el });
});
