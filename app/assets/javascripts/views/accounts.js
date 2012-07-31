var AccountsView = Backbone.View.extend({
  events: {
    'click a[rel="edit"]': 'edit',
    'click a[rel="save"]': 'save',
    'click a[rel="new"]': 'new',
    'click a[rel="cancel"]': 'cancel'
  },
  render: function(){
    if (this.editing) {
      this.$el.html('<a href="#" rel="save">Save</a> <a href="#" rel="new">New</a> <a href="#" rel="cancel">Cancel</a>');
    } else {
      this.$el.html('<a href="#" rel="edit">Edit</a>');
    }
    this.$el.append((new AssetListView({ editing: this.editing })).render().el);
    this.$el.append((new LiabilityListView({ editing: this.editing })).render().el);
    return this;
  },
  edit: function(e){
    e.preventDefault();
    this.editing = true;
    this.render();
  },
  save: function(e){
    var view = this;
    e.preventDefault();
    app.loading();
    app.Accounts.save(function(){
      app.loading(false);
      view.editing = false;
      view.render();
    });
  },
  new: function(e){
    e.preventDefault();
    app.Accounts.add({});
  },
  cancel: function(e){
    var view = this;
    e.preventDefault();
    this.editing = false;
    delete app.Accounts.loaded;
    app.load(app.Accounts, function(){
      view.render();
    })
  }
});
