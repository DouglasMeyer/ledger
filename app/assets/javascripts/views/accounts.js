var AccountsView = Backbone.View.extend({
  render: function(){
    this.assetListView = new AssetListView();
    this.$el.append(this.assetListView.render().el);
    this.liabilityListView = new LiabilityListView();
    this.$el.append(this.liabilityListView.render().el);
    return this;
  }
});
