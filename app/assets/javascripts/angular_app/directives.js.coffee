angular.module('Ledger').directive 'lCurrency', ($filter) ->
  numberFilter = $filter('number')

  require: '?ngModel'
  link: (scope, element, attrs, ngModel) ->
    return unless ngModel

    updateClass = (value) ->
      element.toggleClass 's-negative', (value < 0)

    formatter = (value) ->
      updateClass value
      if value
        value = '$' + numberFilter(value/100, 2)
      value

    parser = (value, strict=false) ->
      if strict || value.match /^\$?-?\d[\d,.]*$/
        value = parseFloat(value.replace(/[^\d.-]/g, ''), 10) || null
        value *= 100 if value
      updateClass value
      value

    ngModel.$parsers.push parser
    ngModel.$formatters.push formatter

    $(element).blur ->
      value = parser element.val(), true
      value = formatter value if value
      element.val value

    if !$(element).is('input')
      ngModel.$render = ->
        value = ngModel.$viewValue
        if typeof value == 'number' || typeof value == 'string'
          element.text ngModel.$viewValue
        else
          element.text ''


angular.module('Ledger').directive 'accountsTable', ->
  restrict: 'E'
  transclude: true
  scope:
    rawGroups: '=groups'
  controller: ($q, $scope)->
    $q.when($scope.rawGroups).then (groups)->
      $scope.groups =
        Assets: groups.Assets
        Liabilities: groups.Liabilities
  template: """
    <div ng-repeat="(category, accounts) in groups" class="{{category | lowercase}}-list">
      <h2>{{category}}</h2>
      <ul>
        <li ng-repeat="account in accounts">
          <div ng-transclude></div>
        </li>
      </ul>
    </div>
  """
