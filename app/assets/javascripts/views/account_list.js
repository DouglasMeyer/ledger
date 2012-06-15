var AccountListView = Backbone.View.extend({
  tagName: 'table',
  render: function(){
    this.$el.html('<caption>'+this.title+'</caption>');
    this.addAll();
    return this;
  },
  addAll: function(){
    var accounts = app.Accounts[this.asset ? 'assets' : 'liabilities']();
    _.each(accounts, this.addOne, this);
  },
  addOne: function(account){
    var view = new AccountView({ model: account });
    this.$el.append(view.render().el);
  }
});

var AssetListView     = AccountListView.extend({ title: 'Assets',      className: 'assets',      asset: true });
var LiabilityListView = AccountListView.extend({ title: 'Liabilities', className: 'liabilities'              });
