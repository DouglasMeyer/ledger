jQuery(function($){
  var table = $('table#bank-entries');
  if (!table.length) return;

  var BankEntryView = Backbone.View.extend({
    tagName: 'tr',
    template: _.template($('#bank-entry-template').html()),
    initialize: function(){
      this.model.bind('change', this.render, this);
      this.model.bind('destroy', this.remove, this);
    },
    render: function(){
      var json = this.model.toJSON(),
          ammount = json.ammount.split('.');
      json.ammount = ammount[0] + '.' + (ammount[1] + '0').substr(0,2);
      this.$el.html(this.template(json));
      return this;
    }
  });
  var BankEntries = new BankEntriesCollection();
  var BankEntriesView = Backbone.View.extend({
    initialize: function(){
      BankEntries.bind('add', this.addOne, this);
      BankEntries.bind('reset', this.addAll, this);
      BankEntries.bind('all', this.render, this);
      BankEntries.fetch();
    },
    render: function(){},
    addOne: function(bankEntry){
      var view = new BankEntryView({ model: bankEntry });
      this.$el.append(view.render().el);
    },
    addAll: function(){
      BankEntries.each(this.addOne, this);
    }
  });

  table.find('tr.bank_entry').remove();
  window.bankEntries = new BankEntriesView({ el: table });
});
