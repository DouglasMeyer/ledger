angular.module('ledger').controller 'AccountsEditCtrl', ($scope, Model, $window, $q)->
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

  categoryAccounts = (category)->
    $scope.accounts.filter((a)-> a.category == category)

  $scope.dragAccount = (account)->
    $scope.draggingAccount = account

  $scope.dropAccount = ->
    delete $scope.draggingAccount

  $scope.dragOverAccount = (e, account)->
    e.originalEvent.dataTransfer.dropEffect = 'move'
    dAccount = $scope.draggingAccount
    if dAccount && dAccount != account
      if account.asset != dAccount.asset
        for a in $scope.accounts when a.asset == dAccount.asset && a.position > dAccount.position
          a.position--
        dAccount.asset = account.asset
        dAccount.position = $scope.accounts.filter((a)-> a.asset == account.asset).length
      newPosition = account.position
      for a in $scope.accounts when a.asset == account.asset
        if newPosition < dAccount.position
          a.position++ if newPosition <= a.position && a.position < dAccount.position
        else
          a.position-- if dAccount.position < a.position && a.position <= newPosition
      dAccount.position = newPosition
      dAccount.category = account.category
