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
    'bank_entries':                'bank_entries',
    'bank_entries/:id/distribute': 'distribute_bank_entry'
  },

  home: function(){
    this.navigate('accounts');
  },
  accounts: function(){
    this._loadCollections('Accounts', function(){
      if (!this.accountsView){
        this.accountsView = new AccountsView();
        this.accountsView.render();
      }
      $app.html(this.accountsView.el);
    });
  },
  bank_entries: function(){
    this._loadCollections('BankEntries', 'Accounts', function(){
      if (!this.bankEntriesView){
        this.bankEntriesView = new BankEntriesView();
        this.bankEntriesView.render();
      }
      $app.html(this.bankEntriesView.el);
    });
  },

  _loadCollections: function(callback){
    if (arguments.length === 1){
      loading.hide();
      callback.apply(app);
    } else {
      var args = _.toArray(arguments),
          collection = args.shift();
      if (app[collection]){
        app._loadCollections.apply(app, args);
      } else {
        loading.show();
        app[collection] = new window[collection+'Collection']();
        app[collection].fetch({
          success: function(){
            app._loadCollections.apply(app, args);
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
