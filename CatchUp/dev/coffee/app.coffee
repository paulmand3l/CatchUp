


angular.module("CatchUp", ["ionic", "ngCordova", "ui.slider"])

.constant 'frequencyScale', do ->
  frequencyScale = []
  for period, frequencyList of { week: [1, 2, 3], month: [1, 2, 3, 4, 6], year: [1] }
    for frequency in frequencyList
      frequencyScale.push
        frequency: frequency
        period: period
  return frequencyScale

.run ($ionicPlatform) ->
  $ionicPlatform.ready ->
    cordova.plugins.Keyboard.hideKeyboardAccessoryBar true  if window.cordova and window.cordova.plugins.Keyboard
    StatusBar.styleDefault()  if window.StatusBar

.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state "home",
    url: "/home"
    templateUrl: "home.html"
    controller: "HomeCtrl"
  .state "edit",
    url: "/edit/:catchUpId"
    templateUrl: "edit.html"
    controller: "EditCtrl"

  $urlRouterProvider.otherwise '/home'

.factory "CatchUps", ->
  all: ->
    catchUpString = window.localStorage["catchUps"]
    if catchUpString then angular.fromJson(catchUpString) else []

  save: (catchUps) ->
    window.localStorage["catchUps"] = angular.toJson catchUps

  get: (index) ->
    catchUpString = window.localStorage["catchUps"]
    angular.fromJson(catchUpString)[index] if catchUpString

  newCatchUp: (contact) ->
    # Add a new project
    person: contact
    frequency: 1
    period: 'month'

.controller 'HomeCtrl', ($scope, $location, CatchUps, $cordovaContacts) ->
  $scope.catchUps = CatchUps.all()
  if $scope.catchUps.length < 1
    $scope.catchUps.push
      person: name: formatted: "Add a catchup"
      frequency: 2
      period: 'month'
  CatchUps.save $scope.catchUps

  $scope.pickContact = ->
    $cordovaContacts.pickContact().then (contact) ->
      newCatchUp = CatchUps.newCatchUp contact

      duplicate = $scope.catchUps.some (catchUp) ->
        catchUp.person.name.formatted is newCatchUp.person.name.formatted

      unless duplicate
        newLength = $scope.catchUps.push newCatchUp
        CatchUps.save $scope.catchUps
        $location.path '/edit/' + (newLength - 1)

.controller 'EditCtrl', ($scope, CatchUps, $stateParams, $ionicNavBarDelegate, frequencyScale) ->
  $scope.catchUps = CatchUps.all()
  $scope.catchUp = $scope.catchUps[$stateParams.catchUpId]

  $ionicNavBarDelegate.changeTitle $scope.catchUp.person.name.formatted, 'forward'

  $scope.frequencyScale = frequencyScale

  $scope.rawFrequency = frequencyScale.indexOf frequencyScale.filter((tick, i) ->
    return tick.frequency is $scope.catchUp.frequency and tick.period is $scope.catchUp.period
  )[0]

  $scope.$watch 'rawFrequency', (newValue, oldValue) ->
    $scope.catchUp.frequency = $scope.frequencyScale[newValue].frequency
    $scope.catchUp.period = $scope.frequencyScale[newValue].period

  $scope.saveCatchUp = () ->
    CatchUps.save $scope.catchUps
    $ionicNavBarDelegate.back()


