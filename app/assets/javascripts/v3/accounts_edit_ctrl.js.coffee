angular.module('ledger').controller 'AccountsEditCtrl', ($scope, Model, $window, $q)->
  $scope.accounts = Model.Account.all

  $scope.save = ->
    promise = $q.all($scope.accounts.map (account)->
      if account.isDeleted
        Model.Account.destroy
          id: account.id
      else
        Model.Account.save
          id: account.id
          asset: account.asset
          position: account.position
          name: account.name
          category: account.category
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

  sortAccounts = (accounts)->
    minPosition = Math.min.apply(null, accounts.map((a)-> a.position))
    accounts
      .sort((a,b)-> a.position - b.position)
      .forEach((a,i)-> a.position = minPosition + i)

  $scope.dragAccount = (account)->
    accounts = categoryAccounts(account.category)
    sortAccounts(accounts)
    $scope.draggingAccount = account

  $scope.dropAccount = ->
    delete $scope.draggingAccount

  $scope.dragOverAccount = (e, account)->
    e.originalEvent.dataTransfer.dropEffect = 'move'
    if $scope.draggingAccount != account
      if $scope.draggingAccount.category != account.category
        accounts = categoryAccounts(account.category)
        minPosition = Math.min.apply(null, accounts.map((a)-> a.position))
        $scope.draggingAccount.position = minPosition + accounts.length
      [ $scope.draggingAccount.position, account.position ] = [ account.position, $scope.draggingAccount.position ]
      $scope.draggingAccount.asset = account.asset
      $scope.draggingAccount.category = account.category
