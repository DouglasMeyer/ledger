var destroyBlank = function(accountEntries){
      accountEntries.filter(function(){
        var accountEntry = $(this);
        return accountEntry.find('select[name$="[account_name]"]').val() === '' ||
               Math.round(accountEntry.find('input[name$="[ammount]"]').val() * 100) === 0;
      }).each(function(){
        $('input[name$="[_destroy]"]', this).val('true');
      });
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
    var form = $(this);
    destroyBlank(form.find('.account-entry'));

    $.ajax({
      url: form.attr('action'),
      data: form.serialize(),
      type: 'PUT',
      context: this,
      complete: function(xhr, status){
        var li = $(this).closest('li');
        li.html(xhr.responseText);
        view.setup(li);
      }
    });

    form.closest('li').next('li').find('select:visible, input:visible').first().focus();

    return false;
  });
};
var DistributeBankEntryView = function(el){
  this.el = $(el);
  var view = this;

  this.el.submit(function(){ destroyBlank($('li', this)); });
  this.el.on('change', 'input[name="distribute_as_income"]', function(){ view.markAsIncome(); });
  this.el.on('change', 'li input[name$="[ammount]"]', function(){ view.updateAccountEntry(this); });
  this.el.on('click', 'li .strategy', function(e){ view.showStrategy(this, e); });

  this.el.find('input[name="distribute_as_income"]').trigger('change');
  this.el.find('li input[name$="[ammount]"]').trigger('change');
};
DistributeBankEntryView.prototype.markAsIncome = function(){
  var isIncome = this.el.find('input[name="distribute_as_income"]').is(':checked'),
      view = this;
  this.el.toggleClass('is-income', isIncome);
  this.el.find('li').each(function(){
    view.useStrategy($(this), isIncome);
  });
};
DistributeBankEntryView.prototype.useStrategy = function(accountEntry, use){
  var ammount = accountEntry.find('input[name$="[ammount]"]'),
      strategy = accountEntry.find('.strategy');
  if (use === undefined) use = true;

  if (use) {
    accountEntry.find('.strategy input').val(strategy.data('id'));
    ammount.currency(strategy.data('value'));
    ammount.trigger('change');
  } else {
    accountEntry.find('.strategy input').val(null);
  }
};
DistributeBankEntryView.prototype.updateAccountEntry = function(input){
  var accountEntry = $(input).closest('li'),
      ammountInput = accountEntry.find('input[name$="[ammount]"]'),
      ammount = ammountInput.currency(),
      strategyAmmount = accountEntry.find('.strategy').data('value'),
      usingStrategy = (ammount === parseFloat(strategyAmmount));

  ammountInput.currency(ammount);
  accountEntry.find('.balance').currency(
    accountEntry.data('account-balance') + ammount
  );
  this.updateDistributeAmmount();
  if (accountEntry.find('.strategy input').val()){
    accountEntry.find('.strategy-dot')
      .toggleClass('using', usingStrategy)
      .toggleClass('not-using', !usingStrategy);
  }
}.delay();
DistributeBankEntryView.prototype.updateDistributeAmmount = function(){
  var ammountRemaining = this.el.data('ammount') * 100;
  this.el.find('li input[name$="[ammount]"]').each(function(){
    ammountRemaining = Math.round(ammountRemaining - this.value.replace(/,/g, '') * 100)
  });
  this.el.find('#distribute-ammount').currency(ammountRemaining / 100);
};
DistributeBankEntryView.prototype.showStrategy = function(control, event){
  var view = this,
      accountEntry = $(control).closest('li'),
      strategyId = accountEntry.find('.strategy').data('id') || 0,
      el = jQuery('<div class="strategy-view"></div>')
        .css({
          position: 'absolute', top: event.pageY, left: event.pageX
        })
        .appendTo(document.body)
        .load('/v2/strategies/'+strategyId+'?'+jQuery.param({
          bank_entry_id: this.el.attr('id').match(/\d+/)[0],
          account_entry: {
            ammount: accountEntry.find('.ammount input').val(),
            account_name: accountEntry.find('.account input').val()
          }
        }));
  el.on('mousedown', function(e){ e.stopPropagation(); });
  $('body').on('mousedown', function(){ el.remove(); });
  el.on('click', 'a.use-strategy', function(e){
    e.preventDefault();
    e.stopImmediatePropagation();
    view.useStrategy(accountEntry);
    el.remove();
  });
  el.on('click', 'a', function(e){
    e.preventDefault();
    el.load(this.href);
  });
  el.on('click', 'form input[type="submit"]', function(e){
    e.preventDefault();
    var form = $(this).closest('form');
    $.ajax({
      type: 'POST',
      url: form.attr('action'),
      data: form.serialize(),
      success: function(data, status, xhr){
        el.html(xhr.responseText);
        accountEntry.find('.strategy')
          .data('id',         el.find('input[name="id"]'   ).val() )
          .data('value',      el.find('input[name="value"]').val() )
          .find('input').val( el.find('input[name="id"]'   ));
        accountEntry.find('input[name$="[ammount]"]').trigger('change');
      },
      complete: function(xhr, status){
        el.html(xhr.responseText);
      }
    });
  });
};

jQuery(function($){
  $('body.bank_entries.index ul.bank-entries').each(function(){ new BankEntriesView(this); });
  $('body.bank_entries.edit form.accounts-table').each(function(){ new DistributeBankEntryView(this); });
});
