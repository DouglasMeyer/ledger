var AccountListView = Backbone.View.extend({
  tagName: 'table',
  initialize: function(options){
    this.itemView = options.editing ? AccountEditView : AccountView;
    app.Accounts.bind('add', this.accountAdded, this);
    _.bindAll(this, 'accountsUpdated');
    this.$el.sortable({
      handle: '.gripper', items: 'tr',
      connectWith: this.asset ? '.liabilities' : '.assets',
      update: this.accountsUpdated
    });
  },
  remove: function(){
    app.Accounts.unbind(null, null, this);
    this.constructor.__super__.remove.apply(this, arguments);
  },
  render: function(){
    this.$el.html('<caption>'+this.title+'</caption>');
    this.addAll();
    return this;
  },
  addAll: function(){
    var accounts = app.Accounts[this.asset ? 'assets' : 'liabilities']();
    accounts = _.sortBy(accounts, function(a){ return a.get('position'); })
    _.each(accounts, this.addOne, this);
  },
  addOne: function(account){
    var view = new this.itemView({ model: account }),
        el = view.render().el;
    $(el).data('view', view);
    this.$el.append(el);
  },
  accountAdded: function(account){
    if (account.get('asset') == this.asset) this.addOne(account);
  },
  accountsUpdated: function(e, ui){
    var asset = this.asset || false;
    this.$('tr').each(function(index){
      var model = $(this).data('view').model;
      model.set({
        asset: asset,
        position: index
      });
    });
  }
});

var AssetListView     = AccountListView.extend({ title: 'Assets',      className: 'assets',      asset: true });
var LiabilityListView = AccountListView.extend({ title: 'Liabilities', className: 'liabilities'              });
