angular.module("CatchUp", ["ionic", "ngCordova"])

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

.controller 'HomeCtrl', ($scope, CatchUps, $cordovaContacts) ->
  $scope.catchUps = CatchUps.all()

  $scope.pickContact = ->
    $cordovaContacts.pickContact().then (contact) ->
      newCatchUp = CatchUps.newCatchUp contact
      $scope.catchUps.push newCatchUp
      CatchUps.save $scope.catchUps

.controller 'EditCtrl', ($scope, CatchUps, $stateParams, $ionicNavBarDelegate) ->
  $scope.catchUp = CatchUps.get $stateParams.catchUpId

  $ionicNavBarDelegate.changeTitle $scope.catchUp.person.name.formatted, 'forward'

