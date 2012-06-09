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
