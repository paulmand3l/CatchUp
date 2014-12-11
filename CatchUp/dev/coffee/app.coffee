angular.module("CatchUp", ["ionic"])

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

.controller 'HomeCtrl', ($scope, $ionicModal, CatchUps) ->
  $scope.catchUps = CatchUps.all()

  $ionicModal.fromTemplateUrl 'contacts.html', (modal) ->
    $scope.contactsModal = modal
  ,
    scope: $scope
    animation: 'slide-in-up'

  $scope.pickContact = ->
    $scope.contactsModal.show()

  $scope.cancelPickContact = ->
    $scope.contactsModal.hide()

  $scope.newCatchUp = (contact) ->
    newCatchUp = CatchUps.newCatchUp contact
    $scope.catchUps.push newCatchUp
    CatchUps.save $scope.catchUps
    $scope.contactsModal.hide()

  $scope.contacts = [
    fullName: "Paul Mandel"
    mobile: "555-555-5555"
  ,
    fullName: "Alex Mandel"
    mobile: "555-555-5555"
  ,
    fullName: "Tess Myers"
    mobile: "555-555-5555"
  ]

.controller 'EditCtrl', ($scope, CatchUps, $stateParams, $ionicNavBarDelegate) ->
  $scope.catchUp = CatchUps.get $stateParams.catchUpId

  $ionicNavBarDelegate.changeTitle $scope.catchUp.person.fullName, 'forward'

