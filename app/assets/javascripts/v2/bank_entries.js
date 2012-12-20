var destroyBlank = function(accountEntries){
      accountEntries.filter(function(){
        var accountEntry = $(this);
        return accountEntry.find('select[name$="[account_name]"]').val() === '' ||
               Math.round(accountEntry.find('input[name$="[ammount]"]').val() * 100) === 0;
      }).each(function(){
        $('input[name$="[_destroy]"]', this).val('true');
      });
    },
    submitBankEntry = function(callback){
      var form = $(this);
      destroyBlank(form.find('.account-entry'));

      $.ajax({
        url: form.attr('action'),
        data: form.serialize(),
        type: 'PUT',
        context: this,
        complete: function(xhr, status){
          $(this).closest('li').html(xhr.responseText);
          callback(this);
        }
      });

      return false;
    };
var BankEntriesView = function(el){
  this.el = $(el);
  this.setup(el);
  var view = this;

  this.el.on('change', 'select, input', function(){
    var form = $(this).closest('form'),
        ammountRemaining = form.data('ammount') * 100;
    // Mark the BankEntry as changed
    form.addClass('changed');
    // Update ammount remaining
    form.find('input[name$="[ammount]"]').each(function(){
      var $this = $(this),
          value = $this.currency();
      $this.currency(value);
      ammountRemaining = Math.round(ammountRemaining - value * 100);
    });
    var blankAccountEntry = form.find('.account-entry').filter(function(){
          return !$('select[name$="[account_name]"]', this).get(0).value;
        }).last();
    if (ammountRemaining !== 0) {
      if (blankAccountEntry.length === 0) {
        var lastAccountEntry = form.find('.account-entry:last'),
            html = lastAccountEntry.get(0).outerHTML
              .replace(/([\[_])\d+([\]_])/g, '$1'+(new Date).getTime()+'$2');
        blankAccountEntry = lastAccountEntry.after(html).next();
      }
      blankAccountEntry.find('input[name$="[ammount]"]').currency(ammountRemaining / 100);
      if (blankAccountEntry.is('.focus')) {
        setTimeout(function(){
          $('select:visible, input:visible', blankAccountEntry).first().focus();
        }, 10);
      }
    }
  });

  // Handle cancel
  this.el.on('click', '.cancel', function(e){
    e.preventDefault();
    var form = $(this).closest('form');
    form.closest('li').load(form.attr('action'), function(){
      view.setup(this);
    });
  });

  // Highlight the account entry
  $('.bank-entries')
    .on('focus', 'select, input', function(){
      $(this).closest('.account-entry').addClass('focus');
    })
    .on('blur', 'select, input', function(){
      $(this).closest('.account-entry').removeClass('focus');
    });
};
BankEntriesView.prototype.setup = function(el){
  var view = this;

  // Format the ammounts
  $(el).find('input[name$="[ammount]"]').each(function(){
    var $this = $(this);
    $this.currency($this.currency());
  });

  // Handle form submissions
  $('form', el).submit(function(){
    submitBankEntry(function(){
      view.setup(this);
    });
  });
};
var DistributeBankEntryView = function(el){
  this.el = $(el);
  var view = this;

  this.el.submit(function(){ destroyBlank($('li', this)); });
  this.el.on('change', 'input', function(){ view.updateAccountEntry(this); });
  this.el.find('li input[name$="[ammount]"]').trigger('change');
};
DistributeBankEntryView.prototype.updateAccountEntry = function(input){
  var bankEntry = $(input).closest('li'),
      ammountInput = bankEntry.find('input[name$="[ammount]"]'),
      ammount = ammountInput.currency();
  ammountInput.currency(ammount);
  bankEntry.find('.balance').currency(
    bankEntry.data('account-balance') + ammount
  );
  this.updateDistributeAmmount();
};
DistributeBankEntryView.prototype.updateDistributeAmmount = function(){
  var ammountRemaining = this.el.data('ammount') * 100;
  this.el.find('li input[name$="[ammount]"]').each(function(){
    ammountRemaining = Math.round(ammountRemaining - this.value * 100)
  });
  this.el.find('#distribute-ammount').currency(ammountRemaining / 100);
};

jQuery(function($){
  $('body.bank_entries.index ul.bank-entries').each(function(){ new BankEntriesView(this); });
  $('body.bank_entries.edit form.accounts-table').each(function(){ new DistributeBankEntryView(this); });
});
