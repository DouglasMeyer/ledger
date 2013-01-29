EditAccountView = (el)->
  @el = $(el)
  view = this

  @el.on 'click', '.up', (e) -> view.accountPositionUp(this, e)
  @el.on 'click', '.down', (e) -> view.accountPositionDown(this, e)

EditAccountView.prototype.accountPositionUp = (el, e) ->
  account = $(el).closest('li')
  previousAccount = account.prev('li')
  if previousAccount.length
    positionPath = 'input[name$="[position]"]'
    position = account.find(positionPath).val()
    previousPosition = previousAccount.find(positionPath).val()
    account.find(positionPath).val( previousPosition )
    previousAccount.find(positionPath).val( position )
    account.remove()
    previousAccount.before( account )

EditAccountView.prototype.accountPositionDown = (el, e) ->
  nextAccount = $(el).closest('li').next('li')
  if nextAccount
    @accountPositionUp nextAccount, e

jQuery ($)->
  $('body.accounts.edit form.accounts-table').each -> new EditAccountView(this)
