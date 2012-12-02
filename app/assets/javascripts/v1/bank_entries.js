jQuery(function($){
  var table = $('#bank-entries');
  if (!table.length) return;
  table.find('.bank-entry-view').remove();
  window.bankEntries = new BankEntriesView({ el: table });
});
