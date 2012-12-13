jQuery(function($){

  var submitBankEntry = function(){
    var $this = $(this),
        accountEntry = $this.closest('.account-entry'),
        ammount = accountEntry.find('input[name$="[ammount]"]').val()*1,
        destroyInput = accountEntry.find('input[name$="[_destroy]"]'),
        form = $this.closest('form');

    destroyInput.val(ammount === 0 ? "true" : "false");

    $.ajax({
      url: form.attr('action'),
      data: form.serialize(),
      type: 'PUT'
    });
    return false;
  };

  $('select, input', '.bank-entries').change(submitBankEntry);
  $('.bank-entries form').submit(submitBankEntry);

});
