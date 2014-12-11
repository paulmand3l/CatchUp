FREQUENCY_SCALE = []
for period, frequencyList of { week: [1, 2, 3], month: [1, 2, 3, 4, 6, 8], year: [1] }
  for f in frequencyList
    FREQUENCY_SCALE.push [f, period]


angular.module("CatchUp", ["ionic", "ngCordova", "ui.slider"])

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
      frequency: 1
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

.controller 'EditCtrl', ($scope, CatchUps, $stateParams, $ionicNavBarDelegate) ->
  $scope.catchUp = CatchUps.get $stateParams.catchUpId

  $scope.FREQUENCY_SCALE = FREQUENCY_SCALE

  $ionicNavBarDelegate.changeTitle $scope.catchUp.person.name.formatted, 'forward'

