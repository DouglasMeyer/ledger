jQuery(function($){
  var el = $('.accounts.distribute');
  if (!el.length) return;

  window.Accounts = new AccountsCollection();

  var AccountView = Backbone.View.extend({
    tagName: 'tr',
    template: _.template($('#account-template').html()),
    initialize: function(){
      this.model.bind('change', this.update, this);
      this.model.bind('destroy', this.remove, this);
    },
    render: function(){
      var json = this.model.toJSON();
      json.balance = centsToCurrency(json.balance_cents);
      this.$el.html(this.template(json));
      this.update();
      return this;
    },
    update: function(){
      this.$('input.account').val(centsToCurrency(0));
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
      this.render();
      Accounts.fetch();
    },
    render: function(){
      var assets = new AssetsView(),
          liabilities = new LiabilitiesView();
      this.$el.append(assets.render().el);
      this.$el.append(liabilities.render().el);
      return this;
    }
  });

  el.empty();
  window.distributeAccount = new DistributeAccountView({ el: el });
});
