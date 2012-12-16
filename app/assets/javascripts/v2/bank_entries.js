jQuery(function($){

  var submitBankEntry = function(){
    var form = $(this);
    form.find('.account-entry').filter(function(){
      var accountEntry = $(this);
      return accountEntry.find('select[name$="[account_name]"]').val() === '' ||
             Math.round(accountEntry.find('input[name$="[ammount]"]') * 100) === 0;
    }).each(function(){
      $('input[name$="[_destroy]"]', this).val('true');
    });

    $.ajax({
      url: form.attr('action'),
      data: form.serialize(),
      type: 'PUT',
      context: this,
      complete: function(xhr, status){
        $(this).closest('li')
          .html(xhr.responseText)
          .find('form')
            .submit(submitBankEntry);
      }
    });

    return false;
  };

  $('.bank-entries').on('change', 'select, input', function(){
    var form = $(this).closest('form'),
        ammountRemaining = form.data('ammount') * 100;
    form.addClass('changed');
    form.find('input[name$="[ammount]"]').each(function(){
      ammountRemaining = Math.round(ammountRemaining - this.value * 100);
    });
    if (ammountRemaining !== 0) {
      var accountEntry = form.find('.account-entry').filter(function(){
        return !$('select[name$="[account_name]"]', this).get(0).value;
      }).last();
      if (accountEntry.length === 0) {
        var lastAccountEntry = form.find('.account-entry:last'),
            html = lastAccountEntry.get(0).outerHTML
              .replace(/([\[_])\d+([\]_])/g, '$1'+(new Date).getTime()+'$2');
        accountEntry = lastAccountEntry.after(html).next();
      }
      accountEntry.find('input[name$="[ammount]"]').val(ammountRemaining / 100);
      if (accountEntry.is('.focus')) {
        setTimeout(function(){
          $('select:visible, input:visible', accountEntry).first().focus();
        }, 10);
      }
    }
  });
  $('.bank-entries form').submit(submitBankEntry);

  // Highlight the account entry
  $('.bank-entries')
    .on('focus', 'select, input', function(){
      $(this).closest('.account-entry').addClass('focus');
    })
    .on('blur', 'select, input', function(){
      $(this).closest('.account-entry').removeClass('focus');
    });

});
