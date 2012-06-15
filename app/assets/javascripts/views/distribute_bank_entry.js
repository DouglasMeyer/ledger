var DistributeBankEntryView = (function(){

  var View = Backbone.View.extend({
    template: _.template(JST['templates/distribute_bank_entry']),
    events: {
      'click input[name="distribute"]': 'distribute'
    },
    initialize: function(){
      this.model.accountEntries.bind('change', this.update, this);
    },
    render: function(){
      var json = this.model.toJSON();
      json.ammount = centsToCurrency(json.ammount_cents);
      this.$el.html(this.template(json));
      this.model.accountEntries.each(function(ae){
        var account = this.accounts.detect(function(a){
          return a.get('name') === ae.get('account_name');
        });
        if (account) account.set('balance_cents', account.get('balance_cents') - ae.get('ammount_cents'));
      }, this);
      var assetListView = new DistributeAssetListView({
        collection: this.model.accountEntries
      });
      assetListView.accounts = this.accounts.assets();
      this.$el.append(assetListView.render().el);
      var liabilityListView = new DistributeLiabilityListView({
        collection: this.model.accountEntries
      });
      liabilityListView.accounts = this.accounts.liabilities();
      this.$el.append(liabilityListView.render().el);
      this.update();
      return this;
    },
    update: function(){
      var distributedAmmount = this.model.accountEntries.reduce(function(acc,ae){
        return acc + ae.get('ammount_cents');
      }, 0);
      this.$('.ammount-to-distribute').html(centsToCurrency(this.model.get('ammount_cents') - distributedAmmount));
    },
    distribute: function(){
      this.model.accountEntries.each(function(ae){
        if (ae.get('ammount_cents') !== 0) ae.save();
      })
      app.load(this.model, this.model.accountEntries, function(){
        app.navigate('bank_entries', { trigger: true });
      });
    }
  });

  var accountListChanges = {
    addAll: function(){
      _.each(this.accounts, this.addOne, this);
    },
    addOne: function(account){
      var view = new DistributeAccountView({ model: account, collection: this.collection });
      this.$el.append(view.render().el);
    }
  };
  var DistributeAssetListView = AssetListView.extend(accountListChanges);
  var DistributeLiabilityListView = LiabilityListView.extend(accountListChanges);

  var DistributeAccountView = AccountView.extend({
    events: {
      'blur input': 'updateValues'
    },
    initialize: function(){
      this.accountEntry = this.collection.detect(function(ae){
        return ae.get('account_name') === this.model.get('name');
      }, this);
      if (!this.accountEntry) {
        this.accountEntry = this.collection.add({
          account_name: this.model.get('name'),
          bank_entry_id: this.collection.bankEntry.get('id')
        }).last();
      }
    },
    render: function(){
      AccountView.prototype.render.apply(this, arguments);
      this.$('.balance').before('<td class="ammount"><input class="currency" /></td>');
      this.update();
      return this;
    },
    update: function(){
      var ammountCents = this.accountEntry.get('ammount_cents'),
          balanceCents = this.model.get('balance_cents') + ammountCents;
      this.$('.ammount input').val(centsToCurrency(ammountCents));
      this.$('.balance').html(centsToCurrency(balanceCents));
    },
    updateValues: function(){
      this.accountEntry.set('ammount_cents', currencyToCents(this.$('.ammount input').val()));
      this.update();
    }
  });

  return View;
})();
