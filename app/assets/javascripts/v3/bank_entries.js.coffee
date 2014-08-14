destroyBlank = (accountEntries) ->
  accountEntries.filter(->
    accountEntry = $(this)
    return accountEntry.find('select:named(account_name)').val() == '' ||
           Math.round(accountEntry.find('input:named(amount)').val() * 100) == 0
  ).each(->
    $('input:named(_destroy)', this).val('true')
  )
class window.BankEntriesView
  constructor: (el)->
    @el = $(el)
    @setup(el)
    view = this

    $('.page-actions .icon-plus').click (e) =>
      e.preventDefault()
      $('<li />', { html: $('#new-bank-entry').html() })
        .prependTo(@el)
        .find('form')
          .attr('id', null)
          .submit(-> view.submitBankEntry(this))
        .end()
        .find('input').trigger('change').end()
        .find('input:visible:first')[0].focus()

    @el.on 'change', 'select, input', ->
      input = $(this)
      updatedAccountEntry = $(this).closest('.account-entry')
      form = updatedAccountEntry.closest('form')
      amountRemaining = form.data('amount') * 100
      # Mark the BankEntry as changed
      form.addClass('changed')
      # Update amount remaining
      form.find('input:named(amount)').each ->
        amount = $(this)
        value = amount.currency()
        amount.currency(value)
        amountRemaining = Math.round(amountRemaining - value * 100)
      blankAccountEntry = form.find('.account-entry').filter(->
        $('select:named(account_name)', this).val() == '' && this != updatedAccountEntry[0]
      ).last()
      if amountRemaining != 0
        if blankAccountEntry.length == 0
          lastAccountEntry = form.find('.account-entry:last')
          html = lastAccountEntry.get(0).outerHTML
            .replace(/([\[_])\d+([\]_])/g, '$1'+(new Date).getTime()+'$2')
          blankAccountEntry = lastAccountEntry.after(html).next()
        else
          amountRemaining = Math.round(amountRemaining + blankAccountEntry.find('input:named(amount)').currency() * 100)
        blankAccountEntry.find('input:named(amount)').currency(amountRemaining / 100)
        blankAccountEntry.find('select:named(account_name)').val(null)

    # Handle cancel
    this.el.on 'click', '.cancel', (e) ->
      e.preventDefault()
      form = $(this).closest('form')
      bankEntry = form.closest('li')
      if form.hasClass('new_bank_entry')
        bankEntry.remove()
      else
        bankEntry.load form.attr('action'), ->
          view.setup(this)

    # Highlight the account entry
    $('.bank-entries')
      .on('focus', 'select, input, a', ->
        $(this).closest('li').addClass('focus')
      )
      .on('blur', 'select, input, a', ->
        $(this).closest('li').removeClass('focus')
      )
  setup: (el)->
    view = this

    # Format the amounts
    $(el).find('input:named(amount)').each ->
      amount = $(this)
      amount.currency(amount.currency())

    # Handle form submissions
    $('form', el).submit -> view.submitBankEntry(this)
  submitBankEntry: (form)->
    form = $(form)
    destroyBlank(form.find('.account-entry'))

    $.ajax
      url: form.attr('action')
      data: form.serialize()
      type: 'POST' # form data should have: _method: 'PUT' / 'POST'
      context: form
      complete: (xhr, status) =>
        li = $(form).closest('li')
        li.html(xhr.responseText)
        @setup(li)

    form.closest('li').next('li').find('select:visible, input:visible').first().focus()

    return false

class window.DistributeBankEntryView
  constructor: (el)->
    @el = $(el)
    view = this

    @el.submit -> destroyBlank($('li', this))
    @el.on 'change', 'input[name="distribute_as_income"]', -> view.markAsIncome()
    @el.on 'change', 'li input:named(amount)', -> view.updateAccountEntry(this)
    @el.on 'click', 'li .strategy', (e)-> view.showStrategy(this, e)

    @el.find('li input:named(amount)').trigger('change')
  markAsIncome: ->
    isIncome = @el.find('input[name="distribute_as_income"]').is(':checked')
    view = this
    @el.toggleClass('is-income', isIncome)
    @el.find('li[data-account-balance]').each (_, ae) => @useStrategy($(ae), isIncome)
  useStrategy: (accountEntry, use)->
    amount = accountEntry.find('input:named(amount)')
    strategy = accountEntry.find('.strategy')
    use = true if use == undefined

    if use
      accountEntry.find('.strategy input').val(strategy.data('id'))
      amount.currency(strategy.data('value'))
      amount.trigger('change')
    else
      accountEntry.find('.strategy input').val(null)
  updateAccountEntry: ((input)->
    accountEntry = $(input).closest('li')
    amountInput = accountEntry.find('input:named(amount)')
    amount = amountInput.currency()
    strategyAmount = accountEntry.find('.strategy').data('value')
    usingStrategy = (amount == parseFloat(strategyAmount))

    amountInput.currency(amount)
    accountEntry.find('.balance').currency(
      parseFloat(accountEntry.data('account-balance')) + amount
    )
    @updateDistributeAmount()
    if accountEntry.find('.strategy input').val()
      accountEntry.find('.strategy-dot')
        .toggleClass('using', usingStrategy)
        .toggleClass('not-using', !usingStrategy)
  ).delay()
  updateDistributeAmount: ->
    amountRemaining = this.el.data('amount') * 100
    this.el.find('li input:named(amount)').each ->
      amountRemaining = Math.round(amountRemaining - this.value.replace(/,/g, '') * 100)
    this.el.find('#distribute-amount').currency(amountRemaining / 100)
  showStrategy: (control, event)->
    view = this
    accountEntry = $(control).closest('li')
    strategyId = accountEntry.find('.strategy').data('id') || 0
    el = jQuery('<div class="strategy-view">Loading ...</div>')
      .css({
        position: 'absolute', top: event.pageY, left: event.pageX
      })
      .appendTo(document.body)
      .load('/v3/strategies/'+strategyId+'?'+jQuery.param({
        bank_entry_id: this.el.attr('id').match(/\d+/)[0],
        account_id: accountEntry.find('.account input').val(),
        entry_amount: accountEntry.find('.amount input').val()
      }))
    el.on 'mousedown', (e)-> e.stopPropagation()
    $('body').on 'mousedown', -> el.remove()
    el.on 'click', 'a.use-strategy', (e)->
      e.preventDefault()
      e.stopImmediatePropagation()
      view.useStrategy(accountEntry)
      el.remove()
    el.on 'click', 'a', (e)->
      e.preventDefault()
      el.load(this.href)
    el.on 'click', 'form input[type="submit"]', (e)->
      e.preventDefault()
      form = $(this).closest('form')
      $.ajax
        type: 'POST'
        url: form.attr('action')
        data: form.serialize()
        success: (data, status, xhr)->
          el.html(xhr.responseText)
          accountEntry.find('.strategy')
            .data('id',         el.find('input[name="id"]'   ).val() )
            .data('value',      el.find('input[name="value"]').val() )
            .find('input').val( el.find('input[name="id"]'   ))
          accountEntry.find('input:named(amount)').trigger('change')
        complete: (xhr, status)->
          el.html(xhr.responseText)

jQuery ($)->
  $('body.bank_entries.index ul.bank-entries').each -> new BankEntriesView(this)
  $('body.bank_entries.edit form.accounts-table').each -> new DistributeBankEntryView(this)
