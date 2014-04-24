class window.StrategyView
  constructor: (el)->
    @el = $(el)
    view = this

    @el.on 'click', '.strategy', (e)-> view.showStrategy(this, e)

  showStrategy: (control, event)->
    view = this
    #accountEntry = $(control).closest('li')
    console.log @el[0]
    strategyId = @el.data('strategy-id') || 0
    accountId  = @el.data('account-id')
    el = jQuery('<div class="strategy-view">Loading ...</div>')
      .css({
        position: 'absolute', top: event.pageY, left: event.pageX
      })
      .appendTo(document.body)
      .load('/v2/strategies/'+strategyId+'?'+jQuery.param({
        account_id: accountId
      }))
    el.on 'mousedown', (e)-> e.stopPropagation()
    $('body').on 'mousedown', -> el.remove()
    #FIXME: remove, not being used
    el.on 'click', 'a.use-strategy', (e)->
      e.preventDefault()
      e.stopImmediatePropagation()
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
          view.el
            .data('strategy-id', el.find('input[name="id"]'   ).val() )
            .find('.strategy')
              .text(el.find('input[name="value"]').val() )
        complete: (xhr, status)->
          el.html(xhr.responseText)

jQuery ($)->
  $('body.strategies.index .accounts-table li').each -> new StrategyView(this)
