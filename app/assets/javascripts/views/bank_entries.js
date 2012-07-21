var BankEntriesView = Backbone.View.extend({
  className: 'bank-entries',
  childViews: [],
  initialize: function(){
    app.BankEntries.bind('add', this.addOne, this);
  },
  remove: function(){
    app.BankEntries.unbind(null, null, this);
    this.constructor.__super__.remove.apply(this, arguments);
  },
  render: function(){
    this.$el.append('<div rel="more">More entries</div>');
    this.addAll();
    this.update();
    var view = this;
    setTimeout(function(){
      view.el.scrollTop = view.el.scrollHeight;
    });
    return this;
  },
  events: {
    'click [rel="more"]': 'loadMore'
  },
  addOne: function(bankEntry){
    var scrollBottom = this.el.scrollTop + this.$el.height() - this.el.scrollHeight;
    var view = new BankEntryView({ model: bankEntry });
    var nextView = _.find(this.childViews, function(childView){
      var childDate = childView.model.get('date'),
          date = bankEntry.get('date');
      if (childDate == date) {
        return childView.model.get('id') > bankEntry.get('id');
      }
      return childDate > date;
    });
    if (nextView){
      var index = this.childViews.indexOf(nextView);
      this.childViews.splice(index, 0, view);
      nextView.$el.before(view.render().el);
    } else {
      this.childViews.push(view);
      this.$el.append(view.render().el);
    }
    this.el.scrollTop = scrollBottom + this.el.scrollHeight - this.$el.height();
  },
  addAll: function(){
    app.BankEntries.each(this.addOne, this);
  },
  loadMore: function(){
    var view = this;
    app.BankEntries.loadMore({
      success: function(){
        view.update();
      }
    });
  },
  update: function(){
    this.$('[rel="more"]')[app.BankEntries.more ? 'show' : 'hide']();
  }
});
