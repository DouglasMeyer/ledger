destroyBlank = (accountEntries) ->
  accountEntries.filter(->
    accountEntry = $(this)
    return accountEntry.find('select[name$="[account_name]"]').val() == '' ||
           Math.round(accountEntry.find('input[name$="[ammount]"]').val() * 100) == 0
  ).each(->
    $('input[name$="[_destroy]"]', this).val('true')
  )
BankEntriesView = (el)->
  @el = $(el)
  #FIXME: el is @el, fix?
  @setup(el)
  view = this

  @el.on 'change', 'select, input', ->
    form = $(this).closest('form')
    ammountRemaining = form.data('ammount') * 100
    # Mark the BankEntry as changed
    form.addClass('changed')
    # Update ammount remaining
    form.find('input[name$="[ammount]"]').each ->
      ammount = $(this)
      value = ammount.currency()
      ammount.currency(value)
      ammountRemaining = Math.round(ammountRemaining - value * 100)
    blankAccountEntry = form.find('.account-entry').filter(->
      !$('select[name$="[account_name]"]', this).get(0).value
    ).last()
    if ammountRemaining != 0
      if blankAccountEntry.length == 0
        lastAccountEntry = form.find('.account-entry:last')
        html = lastAccountEntry.get(0).outerHTML
          .replace(/([\[_])\d+([\]_])/g, '$1'+(new Date).getTime()+'$2')
        blankAccountEntry = lastAccountEntry.after(html).next()
      blankAccountEntry.find('input[name$="[ammount]"]').currency(ammountRemaining / 100)
      if form.find('input[type="submit"]:focus')
        setTimeout(->
          $('select:visible, input:visible', blankAccountEntry).first().focus()
        , 10)

  # Handle cancel
  this.el.on 'click', '.cancel', (e) ->
    e.preventDefault()
    form = $(this).closest('form')
    form.closest('li').load form.attr('action'), ->
      view.setup(this)

  # Highlight the account entry
  $('.bank-entries')
    .on('focus', 'select, input', ->
      $(this).closest('li').addClass('focus')
    )
    .on('blur', 'select, input', ->
      $(this).closest('li').removeClass('focus')
    )
BankEntriesView.prototype.setup = (el)->
  view = this

  # Format the ammounts
  $(el).find('input[name$="[ammount]"]').each ->
    ammount = $(this)
    ammount.currency(ammount.currency())

  # Handle form submissions
  $('form', el).submit ->
    form = $(this)
    destroyBlank(form.find('.account-entry'))

    $.ajax
      url: form.attr('action')
      data: form.serialize()
      type: 'PUT'
      context: this
      complete: (xhr, status) ->
        li = $(this).closest('li')
        li.html(xhr.responseText)
        view.setup(li)

    form.closest('li').next('li').find('select:visible, input:visible').first().focus()

    return false
DistributeBankEntryView = (el)->
  @el = $(el)
  view = this

  @el.submit -> destroyBlank($('li', this))
  @el.on 'change', 'input[name="distribute_as_income"]', -> view.markAsIncome()
  @el.on 'change', 'li input[name$="[ammount]"]', -> view.updateAccountEntry(this)
  @el.on 'click', 'li .strategy', (e)-> view.showStrategy(this, e)

  @el.find('input[name="distribute_as_income"]').trigger('change')
  @el.find('li input[name$="[ammount]"]').trigger('change')
DistributeBankEntryView.prototype.markAsIncome = ->
  isIncome = this.el.find('input[name="distribute_as_income"]').is(':checked')
  view = this
  this.el.toggleClass('is-income', isIncome)
  this.el.find('li').each ->
    view.useStrategy($(this), isIncome)
DistributeBankEntryView.prototype.useStrategy = (accountEntry, use)->
  ammount = accountEntry.find('input[name$="[ammount]"]')
  strategy = accountEntry.find('.strategy')
  use = true if use == undefined

  if use
    accountEntry.find('.strategy input').val(strategy.data('id'))
    ammount.currency(strategy.data('value'))
    ammount.trigger('change')
  else
    accountEntry.find('.strategy input').val(null)
DistributeBankEntryView.prototype.updateAccountEntry = ((input)->
  accountEntry = $(input).closest('li')
  ammountInput = accountEntry.find('input[name$="[ammount]"]')
  ammount = ammountInput.currency()
  strategyAmmount = accountEntry.find('.strategy').data('value')
  usingStrategy = (ammount == parseFloat(strategyAmmount))

  ammountInput.currency(ammount)
  accountEntry.find('.balance').currency(
    parseFloat(accountEntry.data('account-balance')) + ammount
  )
  @updateDistributeAmmount()
  if accountEntry.find('.strategy input').val()
    accountEntry.find('.strategy-dot')
      .toggleClass('using', usingStrategy)
      .toggleClass('not-using', !usingStrategy)
).delay()
DistributeBankEntryView.prototype.updateDistributeAmmount = ->
  ammountRemaining = this.el.data('ammount') * 100
  this.el.find('li input[name$="[ammount]"]').each ->
    ammountRemaining = Math.round(ammountRemaining - this.value.replace(/,/g, '') * 100)
  this.el.find('#distribute-ammount').currency(ammountRemaining / 100)
DistributeBankEntryView.prototype.showStrategy = (control, event)->
  view = this
  accountEntry = $(control).closest('li')
  strategyId = accountEntry.find('.strategy').data('id') || 0
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
        accountEntry.find('input[name$="[ammount]"]').trigger('change')
      complete: (xhr, status)->
        el.html(xhr.responseText)

jQuery ($)->
  $('body.bank_entries.index ul.bank-entries').each -> new BankEntriesView(this)
  $('body.bank_entries.edit form.accounts-table').each -> new DistributeBankEntryView(this)
