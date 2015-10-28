angular.module('ledger')
.controller 'AccountsEditCtrl', ($scope, Model, $window, $q)->
  $scope.accounts = Model.Account.all

  sortAccounts = ->
    for isAsset in [ true, false ]
      i=0
      categories = $scope.accounts
        .filter((a)-> a.asset == isAsset)
        .sort((a,b)-> a.position - b.position)
        .map((a)-> a.category)
        .reduce((l,e) ->
          l.push(e) unless e in l
          l
        , [])
      for category in categories
        $scope.accounts
          .filter((a)-> a.asset == isAsset && a.category == category)
          .sort((a,b)-> a.position - b.position)
          .forEach((a)-> a.position = i++)

  sortAccounts()
  $q.when(Model.Account.promise).then sortAccounts


  $scope.save = ->
    promise = $q.all($scope.accounts.map (account)->
      args =
        id: account.id
        asset: account.asset
        position: account.position
        name: account.name
        category: account.category
      if account.isDeleted
        if account.id
          Model.Account.destroy args
      else
        Model.Account.save args
    ).then ->
      $window.location = '#/accounts'
    $scope.$root.$emit 'status',
      text: 'saving'
      promise: promise

  $scope.updateCategory = (e)->
    oldValue = e.target.defaultValue
    newValue = e.target.value
    $scope.accounts.forEach (account)->
      account.category = newValue if account.category == oldValue

  $scope.addNewAccount = (e, isAsset, category)->
    return if e.target.value == ''
    positionForCategory = $scope.accounts
      .filter((account)-> account.category == category)
      .map((account)-> account.position)
    $scope.accounts.push({
      asset: isAsset,
      category: category,
      name: e.target.value,
      position: Math.max.apply(null, positionForCategory) + 1
    })
    e.target.value = ''

  $scope.addNewCategory = (e, isAsset)->
    return if e.target.value == ''
    $scope.accounts.push({
      asset: isAsset,
      category: e.target.value,
      name: e.target.value + ' account'
      position: 0
    })
    e.target.value = ''

  $scope.drop = (e)->
    e.stopPropagation()
    delete $scope.draggingAccount
    delete $scope.draggingCategory
    false

  $scope.dragAccount = (account)->
    $scope.draggingAccount = account

  $scope.dragOverAccount = (e, account)->
    return true unless dAccount = $scope.draggingAccount
    e.preventDefault()
    e.originalEvent.dataTransfer.dropEffect = 'move'
    if dAccount != account
      dAccount.asset = account.asset
      dAccount.category = account.category
      if account.position < dAccount.position
        dAccount.position = account.position - 0.001
      else
        dAccount.position = account.position + 0.001
      sortAccounts()
    false

  $scope.dragCategory = (asset, category)->
    $scope.draggingCategory =
      asset: asset
      name: category

  $scope.dragOverCategory = (e, asset, category)->
    return true unless dCategory = $scope.draggingCategory
    e.preventDefault()
    e.originalEvent.dataTransfer.dropEffect = 'move'
    if dCategory.name != category
# coffeelint: disable=max_line_length
      dCategoryAccounts = $scope.accounts
        .filter((a)-> a.asset == dCategory.asset && a.category == dCategory.name)
        .sort((a,b)-> a.position - b.position)
# coffeelint: enable=max_line_length
      tCategoryAccounts = $scope.accounts
        .filter((a)-> a.asset == asset && a.category == category)
        .sort((a,b)-> a.position - b.position)

      a.asset = asset for a in dCategoryAccounts
      dCategory.asset = asset
      if tCategoryAccounts[0].position < dCategoryAccounts[0].position
        start = tCategoryAccounts[0].position - 1
      else
        start = tCategoryAccounts[0].position
      dCategoryAccounts.forEach (a, index)->
        a.position = start + (index+1) * 0.001
      sortAccounts()
    false

  $scope.dragOverAccountType = (e, asset)->
    return true unless dCategory = $scope.draggingCategory
    e.preventDefault()
    e.originalEvent.dataTransfer.dropEffect = 'move'
    if dCategory.asset != asset
# coffeelint: disable=max_line_length
      dCategoryAccounts = $scope.accounts
        .filter((a)-> a.asset == dCategory.asset && a.category == dCategory.name)
        .sort((a,b)-> a.position - b.position)
# coffeelint: enable=max_line_length

      a.asset = asset for a in dCategoryAccounts
      dCategory.asset = asset

      start = $scope.accounts.filter((a)-> a.asset == asset).length
      dCategoryAccounts.forEach (a, index)->
        a.position = start + (index+1) * 0.001
      sortAccounts()
    false
