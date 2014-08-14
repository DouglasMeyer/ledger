//= require jquery
//= require test_it
//= require v2

view = null
accountEntryHtml = (accountEntry)->
  time = (new Date()).getTime()
  """
  <div class="account-entry">
    <input type="hidden" name="bank_entry[account_entries_attributes][#{time}][_destroy]" />
    <div class="account">
      <select name="bank_entry[account_entries_attributes][#{time}][account_name]">
        <option#{if accountEntry.accountName == '' then ' selected="selected"' else ''} value=""></option>
        <option#{if accountEntry.accountName == 'Groceries' then ' selected="selected"' else ''} value="Groceries">Groceries</option>
      </select>
    </div>
    <div class="amount">
      <input type="text" name="bank_entry[account_entries_attributes][#{time}][amount]" />
    </div>
  </div>
  """

bankEntryHtml = (bankEntry)->
  """
  <li>
    <form action="#" data-amount="#{bankEntry.amount}">
      <div class="date">#{bankEntry.date}</div>
      <div class="description">#{bankEntry.description}</div>
      <div class="distribute"><a href="#">Distrubute</a></div>
      #{(accountEntryHtml(accountEntry) for accountEntry in bankEntry.accountEntries).join('')}
      <div class="actions">
        <input type="submit" value="Save" />
        <a href="#" class="cancel">cancel</a>
      </div>
    </form>
  </li>
  """

TestIt 'BankEntriesView',

  'before all': ->
    @waitFor ->
      jQuery.isReady
    , ->

  'before each': ->
    $(document.body).addClass('bank_entries index')
    view = $ "<ul />",
      class: 'bank-entries'
    .append(bankEntryHtml
      amount: -12.34
      date: '2013-02-04'
      description: 'WAL MART SUPER WOODSTOCK'
      accountEntries: [
        accountName: 'Groceries'
      ]
    )
    .appendTo document.body
    new BankEntriesView(view)

  'after each': ->
    view.remove()

  'changing the amount when there is more to distribute':
    'should create a new account entry': ->
      view.find('.account-entry:eq(0)')
        .find('[name$="[account_name]"]').val('Groceries').end()
        .find('[name$="[amount]"]').val(10).trigger('change')
      @assertEqual '', view.find('.account-entry:eq(1) [name$="[account_name]"]').val()
      @assertEqual '-22.34', view.find('.account-entry:eq(1) [name$="[amount]"]').val()
      view.find('.account-entry:eq(0) [name$="[amount]"]').val(-10).trigger('change')
      @assertEqual '-2.34', view.find('.account-entry:eq(1) [name$="[amount]"]').val()

    'should update the last blank account entry': ->
      view.find('.account-entry:eq(0)')
        .find('[name$="[account_name]"]').val('Groceries').end()
        .find('[name$="[amount]"]').val(10).trigger('change')
      @assertEqual '-22.34', view.find('.account-entry:eq(1) [name$="[amount]"]').val()
      view.find('.account-entry:eq(0)')
        .find('[name$="[amount]"]').val(15).trigger('change')
      @assertEqual '-27.34', view.find('.account-entry:eq(1) [name$="[amount]"]').val()

    'should not update the last blank account entry if it is what was changed': ->
      view.find('.account-entry:eq(0)')
        .find('[name$="[account_name]"]').val('Groceries').end()
        .find('[name$="[amount]"]').val(10).trigger('change')
      @assertEqual '-22.34', view.find('.account-entry:eq(1) [name$="[amount]"]').val()
      view.find('.account-entry:eq(1)')
        .find('[name$="[amount]"]').val(5).trigger('change')
      @assertEqual '5.00', view.find('.account-entry:eq(1) [name$="[amount]"]').val()
