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
    this._loadAccounts(function(){
      this.accountsView = new AccountsView();
      $app.html(this.accountsView.render().el);
    });
  },

  _loadAccounts: function(callback){
    if (this.Accounts){
      callback.apply(this);
    } else {
      loading.show();
      this.Accounts = new AccountsCollection();
      this.Accounts.fetch({
        success: function(){
          loading.hide();
          callback.apply(this);
        }
      });
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
    app.navigate('accounts');
  });
});
