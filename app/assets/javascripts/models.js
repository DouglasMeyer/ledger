var Account = Backbone.Model.extend({
  urlRoot: '/accounts'
});

var AccountEntry = Backbone.Model.extend({
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

var BankEntry = Backbone.Model.extend({
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

