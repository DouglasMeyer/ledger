var AccountsView = Backbone.View.extend({
  render: function(){
    this.$el.append((new AssetListView()).render().el);
    this.$el.append((new LiabilityListView()).render().el);
    return this;
  }
});
