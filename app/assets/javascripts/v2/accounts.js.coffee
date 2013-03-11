class window.EditAccountView
  constructor: (el)->
    @el = $(el)

    @el.on 'click', 'h2 .icon-plus', (e) => @addAccount(e)
    @el.on 'click', '.up', (e) => @accountPositionUp(e)
    @el.on 'click', '.down', (e) => @accountPositionDown(e)
    @el.on 'change', 'input:named(_destroy)', (e) => @markAsDeleted(e)

  addAccount: (e)->
    templateAccount = @el.find('.template')
    accountList = $(e.target).closest('h2').next('ul')
    $('<li />',
      html: templateAccount.html().replace(/\[\d+\]/g, "[#{(new Date()).valueOf()}]")
    ).appendTo(accountList)
      .find('input:named(position)').val(accountList.find('li:last').val('input:named(position)') + 1).end()
      .find('input:named(_destroy)').val('').end()
      .find('input:named(asset)').val(accountList.parent('.assets-list').length != 0).end()
      .find('.balance').text('$0.00').end()
      .find('.name input').val('').focus()

  accountPositionUp: (e)->
    account = $(e.target).closest('li')
    previousAccount = account.prevAll('li:first')
    if previousAccount.length
      @swapPositions previousAccount, account

  accountPositionDown: (e)->
    account = $(e.target).closest('li')
    nextAccount = account.nextAll('li:first')
    if nextAccount
      @swapPositions account, nextAccount

  swapPositions: (first_account, second_account)->
    position = first_account.find('input:named(position)').val()
    first_account.find('input:named(position)').val( second_account.find('input:named(position)').val() )
    second_account.find('input:named(position)').val( position )

    second_account.remove()
    first_account.before( second_account )

  markAsDeleted: (e)->
    account = $(e.target).closest('li')
    deleted = account.find('input:named(_destroy)').val()
    account.toggleClass('deleted', deleted)

jQuery ($)->
  $('body.accounts.edit form.accounts-table').each -> new EditAccountView(this)
