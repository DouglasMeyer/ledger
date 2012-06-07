// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require underscore-1.3.3-min
//= require backbone-0.9.2-min
//= require_self
//= require_tree .

window.centsToCurrency = function(cents){
  var string = (cents + '').split(''),
      cents = [],
      negative = string[0] === '-';
  if (negative) { string.shift(); }
  cents.unshift(string.pop() || '0');
  cents.unshift(string.pop() || '0');
  return (negative ? '-' : '') + (string.join('') || '0') + '.' + cents.join('');
};
window.currencyToCents = function(currency){
  return currency ? Math.round(parseFloat(currency) * 100) : 0;
};

window.BankEntry = Backbone.Model.extend({
  initialize: function(){
    this.accountEntries = new AccountEntriesCollection();
    this.accountEntries.url += '?bank_entry=' + this.get('id');

    this.set('ammount_cents', parseInt(this.get('ammount_cents')));
  },
  accountEntryAmmountCentsDifference: function(){
    var sum = this.accountEntries.reduce(function(sum, entry){
      return sum + entry.get('ammount_cents');
    }, 0);
    return this.get('ammount_cents') - sum;
  }
});
window.Account = Backbone.Model.extend({
  urlRoot: '/accounts'
});
window.AccountEntry = Backbone.Model.extend({
  initialize: function(){
    this.set('ammount_cents', parseInt(this.get('ammount_cents')));
  },
  defaults: {
    account_name: '',
    notes: ''
  },
  urlRoot: '/account_entries',
  sync: function(method, model, options){
    options = _.extend({}, {
      contentType: 'application/json',
      data: JSON.stringify({ account_entry: {
        bank_entry_id: model.get('bank_entry_id'),
                notes: model.get('notes'),
        ammount_cents: model.get('ammount_cents'),
         account_name: model.get('account_name')
      } })
    }, options);
    return Backbone.sync.apply(this, arguments);
  }
});

window.BankEntriesCollection = Backbone.Collection.extend({
  model: BankEntry,
  url: '/bank_entries'
});
window.AccountsCollection = Backbone.Collection.extend({
  model: Account,
  url: '/accounts',

  assets:      function(){ return this.filter(function(a){ return  a.get('asset'); }); },
  liabilities: function(){ return this.filter(function(a){ return !a.get('asset'); }); }
});
window.AccountEntriesCollection = Backbone.Collection.extend({
  model: AccountEntry,
  url: '/account_entries'
});
