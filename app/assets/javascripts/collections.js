var BankEntriesCollection = Backbone.Collection.extend({
  model: BankEntry,
  url: '/bank_entries'
});

var AccountsCollection = Backbone.Collection.extend({
  model: Account,
  url: '/accounts',

  assets:      function(){ return this.filter(function(a){ return  a.get('asset'); }); },
  liabilities: function(){ return this.filter(function(a){ return !a.get('asset'); }); }
});

var AccountEntriesCollection = Backbone.Collection.extend({
  model: AccountEntry,
  url: '/account_entries'
});

var Accounts = new AccountsCollection();
var AccountEntries = new AccountEntriesCollection();
var BankEntries = new BankEntriesCollection();
