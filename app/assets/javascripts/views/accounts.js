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
