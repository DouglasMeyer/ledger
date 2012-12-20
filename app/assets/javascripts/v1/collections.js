var BankEntriesCollection = Collection.extend({
  model: BankEntry,
  url: '/api/bank_entries',
  loadMore: function(options){
    options.url = this.more;
    options.add = true;
    this.fetch(options);
  }
});

var AccountsCollection = Collection.extend({
  model: Account,
  url: '/api/accounts',

  assets:      function(){ return this.filter(function(a){ return  a.get('asset'); }); },
  liabilities: function(){ return this.filter(function(a){ return !a.get('asset'); }); }
});

var AccountEntriesCollection = Collection.extend({
  model: AccountEntry,
  url: '/api/account_entries'
});
