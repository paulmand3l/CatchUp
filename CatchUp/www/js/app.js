(function() {
  angular.module("CatchUp", ["ionic"]).run(function($ionicPlatform) {
    return $ionicPlatform.ready(function() {
      if (window.cordova && window.cordova.plugins.Keyboard) {
        cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      }
      if (window.StatusBar) {
        return StatusBar.styleDefault();
      }
    });
  }).config(function($stateProvider, $urlRouterProvider) {
    $stateProvider.state("home", {
      url: "/home",
      templateUrl: "home.html",
      controller: "HomeCtrl"
    }).state("edit", {
      url: "/edit/:catchUpId",
      templateUrl: "edit.html",
      controller: "EditCtrl"
    });
    return $urlRouterProvider.otherwise('/home');
  }).factory("CatchUps", function() {
    return {
      all: function() {
        var catchUpString;
        catchUpString = window.localStorage["catchUps"];
        if (catchUpString) {
          return angular.fromJson(catchUpString);
        } else {
          return [];
        }
      },
      save: function(catchUps) {
        return window.localStorage["catchUps"] = angular.toJson(catchUps);
      },
      get: function(index) {
        var catchUpString;
        catchUpString = window.localStorage["catchUps"];
        if (catchUpString) {
          return angular.fromJson(catchUpString)[index];
        }
      },
      newCatchUp: function(contact) {
        return {
          person: contact,
          frequency: 1,
          period: 'month'
        };
      }
    };
  }).controller('HomeCtrl', function($scope, $ionicModal, CatchUps) {
    $scope.catchUps = CatchUps.all();
    $ionicModal.fromTemplateUrl('contacts.html', function(modal) {
      return $scope.contactsModal = modal;
    }, {
      scope: $scope,
      animation: 'slide-in-up'
    });
    $scope.pickContact = function() {
      return $scope.contactsModal.show();
    };
    $scope.cancelPickContact = function() {
      return $scope.contactsModal.hide();
    };
    $scope.newCatchUp = function(contact) {
      var newCatchUp;
      newCatchUp = CatchUps.newCatchUp(contact);
      $scope.catchUps.push(newCatchUp);
      CatchUps.save($scope.catchUps);
      return $scope.contactsModal.hide();
    };
    return $scope.contacts = [
      {
        fullName: "Paul Mandel",
        mobile: "555-555-5555"
      }, {
        fullName: "Alex Mandel",
        mobile: "555-555-5555"
      }, {
        fullName: "Tess Myers",
        mobile: "555-555-5555"
      }
    ];
  }).controller('EditCtrl', function($scope, CatchUps, $stateParams, $ionicNavBarDelegate) {
    $scope.catchUp = CatchUps.get($stateParams.catchUpId);
    return $ionicNavBarDelegate.changeTitle($scope.catchUp.person.fullName, 'forward');
  });

}).call(this);
