EditAccountView = (el)->
  @el = $(el)

  @el.on 'click', '.up', (e) => @accountPositionUp(e)
  @el.on 'click', '.down', (e) => @accountPositionDown(e)

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
  positionPath = 'input[name$="[position]"]'

  position = first_account.find(positionPath).val()
  first_account.find(positionPath).val( second_account.find(positionPath).val() )
  second_account.find(positionPath).val( position )

  second_account.remove()
  first_account.before( second_account )

jQuery ($)->
  $('body.accounts.edit form.accounts-table').each -> new EditAccountView(this)
