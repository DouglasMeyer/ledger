EditAccountView = (el)->
  @el = $(el)

  @el.on 'click', 'h2 .icon-plus', (e) => @addAccount(e)
  @el.on 'click', '.up', (e) => @accountPositionUp(e)
  @el.on 'click', '.down', (e) => @accountPositionDown(e)
  @el.on 'change', 'input:named(_destroy)', (e) => @markAsDeleted(e)

EditAccountView.prototype.addAccount = (e) ->
  lastAccount = $(e.target).closest('h2').next('ul').find('li:last')
  $('<li />',
    html: lastAccount.html().replace(/\[\d+\]/g, "[#{(new Date()).valueOf()}]")
  ).insertAfter(lastAccount)
    .find('input:named(position)').val(lastAccount.find().val('input:named(position)') + 1).end()
    .find('input:named(_destroy)').val('').end()
    .find('.balance').text('$0.00').end()
    .find('.name input').val('').focus()

EditAccountView.prototype.accountPositionUp = (e) ->
  account = $(e.target).closest('li')
  previousAccount = account.prevAll('li:first')
  if previousAccount.length
    @swapPositions previousAccount, account

EditAccountView.prototype.accountPositionDown = (e) ->
  account = $(e.target).closest('li')
  nextAccount = account.nextAll('li:first')
  if nextAccount
    @swapPositions account, nextAccount

EditAccountView.prototype.swapPositions = (first_account, second_account) ->
  position = first_account.find('input:named(position)').val()
  first_account.find('input:named(position)').val( second_account.find('input:named(position)').val() )
  second_account.find('input:named(position)').val( position )

  second_account.remove()
  first_account.before( second_account )

EditAccountView.prototype.markAsDeleted = (e) ->
  account = $(e.target).closest('li')
  deleted = account.find('input:named(_destroy)').val()
  account.toggleClass('deleted', deleted)

jQuery ($)->
  $('body.accounts.edit form.accounts-table').each -> new EditAccountView(this)
