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

window.BankEntry = Backbone.Model.extend();
window.Account = Backbone.Model.extend();
window.AccountEntry = Backbone.Model.extend();

window.BankEntriesCollection = Backbone.Collection.extend({
  model: BankEntry,
  url: '/bank_entries'
});
window.AccountsCollection = Backbone.Collection.extend({
  model: Account,
  url: '/accounts'
});
window.AccountEntriesCollection = Backbone.Collection.extend({
  model: AccountEntry,
  url: '/account_entries'
});
