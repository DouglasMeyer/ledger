//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require haml
//= require underscore-1.3.3-min
//= require backbone-0.9.2-min
//= require ./helpers
//= require ./models
//= require ./collections
//= require_tree .
//= require_self

var loading, $app;
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
    this.navigate('accounts');
  },
  accounts: function(){
    this.load(this.Accounts, function(){
      if (!this.accountsView){
        this.accountsView = new AccountsView();
        this.accountsView.render();
      }
      $app.html(this.accountsView.el);
    });
  },
  bank_entries: function(){
    this.load(this.Accounts, this.BankEntries, function(){
      if (!this.bankEntriesView){
        this.bankEntriesView = new BankEntriesView();
        this.bankEntriesView.render();
      }
      $app.html(this.bankEntriesView.el);
    });
  },
  bank_entry: function(id){
    var accounts = new AccountsCollection();
    var bankEntry = new BankEntry({ id: id });
    this.load(accounts, bankEntry, bankEntry.accountEntries, function(){
      var view = new DistributeBankEntryView({ model: bankEntry });
      view.accounts = accounts;
      $app.html(view.render().el);
    });
  },

  load: function(callback){
    if (arguments.length === 1){
      loading.hide();
      callback.apply(this);
    } else {
      var args = _.toArray(arguments),
          fetchable = args.shift();
      if (fetchable.loaded) {
        this.load.apply(this, args);
      } else {
        loading.show();
        fetchable.fetch({
          success: function(){
            fetchable.loaded = true;
            app.load.apply(app, args);
          }
        });
      }
    }
  }
});

jQuery(function($){
  loading = $('.loading');
  $app = $('.app');
  window.app = new AppRouter();
  Backbone.history.start();

  $('.navigation .accounts').click(function(e){
    e.preventDefault();
    app.navigate('accounts', { trigger: true });
  });
  $('.navigation .bank_entries').click(function(e){
    e.preventDefault();
    app.navigate('bank_entries', { trigger: true });
  });
});
