//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require haml
//= require underscore-1.3.3-min
//= require backbone-0.9.2-min
//= require ./v1/helpers
//= require ./v1/lib
//= require ./v1/models
//= require ./v1/collections
//= require_tree ./v1/
//= require_self

var loading, $app, currentView;
var AppRouter = Backbone.Router.extend({
  routes: {
    '': 'home',
    'accounts':     'accounts',
    'accounts/new': 'new_account',
    'accounts/:id': 'account',
    'bank_entries':     'bank_entries',
    'bank_entries/:id': 'bank_entry'
  },

  initialize: function(){
    this.Accounts = new AccountsCollection();
    this.BankEntries = new BankEntriesCollection();
  },

  home: function(){
    this.navigate('accounts', { trigger: true });
  },
  accounts: function(){
    $('.navigation .current').removeClass('current');
    $('.navigation [rel="accounts"]').addClass('current');
    this.showView(null);
    this.load(this.Accounts, function(){
      this.showView(new AccountsView());
    });
  },
  bank_entries: function(){
    $('.navigation .current').removeClass('current');
    $('.navigation [rel="bank_entries"]').addClass('current');
    this.showView(null);
    this.load(this.Accounts, this.BankEntries, function(){
      this.showView(new BankEntriesView());
    });
  },
  bank_entry: function(id){
    this.showView(null);
    var accounts = new AccountsCollection(),
        bankEntry = new BankEntry({ id: id });
    if (app.BankEntries.loaded) {
      bankEntry = app.BankEntries.get(id);
    }
    this.load(accounts, bankEntry, function(){
      var view = new DistributeBankEntryView({ model: bankEntry, accounts: accounts });
      this.showView(view);
    });
  },

  loading: function(isLoading){
    loading[isLoading === false ? 'hide' : 'show']();
  },
  load: function(callback){
    if (arguments.length === 1){
      this.loading(false);
      callback.apply(this);
    } else {
      var args = _.toArray(arguments),
          fetchable = args.shift();
      if (fetchable.loaded) {
        this.load.apply(this, args);
      } else {
        this.loading();
        fetchable.fetch({
          success: function(){
            fetchable.loaded = true;
            app.load.apply(app, args);
          }
        });
      }
    }
  },
  showView: function(view){
    if (currentView) {
      currentView.remove();
      currentView.unbind();
      delete currentView;
    }
    if (view) {
      currentView = view;
      $app.html(view.render().el);
    }
  }
});

jQuery(function($){
  loading = $('.loading');
  $app = $('.app');
  window.app = new AppRouter();
  Backbone.history.start();

  $('.navigation [rel="accounts"]').click(function(e){
    e.preventDefault();
    app.navigate('accounts', { trigger: true });
  });
  $('.navigation [rel="bank_entries"]').click(function(e){
    e.preventDefault();
    app.navigate('bank_entries', { trigger: true });
  });
});
