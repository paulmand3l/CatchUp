(function() {
  angular.module("CatchUp", ["ionic", "ngCordova"]).run(function($ionicPlatform) {
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
  }).controller('HomeCtrl', function($scope, CatchUps, $cordovaContacts) {
    $scope.catchUps = CatchUps.all();
    return $scope.pickContact = function() {
      return $cordovaContacts.pickContact().then(function(contact) {
        var duplicate, newCatchUp;
        newCatchUp = CatchUps.newCatchUp(contact);
        duplicate = $scope.catchUps.some(function(catchUp) {
          return catchUp.person.name.formatted === newCatchUp.person.name.formatted;
        });
        if (!duplicate) {
          $scope.catchUps.push(newCatchUp);
          return CatchUps.save($scope.catchUps);
        }
      });
    };
  }).controller('EditCtrl', function($scope, CatchUps, $stateParams, $ionicNavBarDelegate) {
    $scope.catchUp = CatchUps.get($stateParams.catchUpId);
    return $ionicNavBarDelegate.changeTitle($scope.catchUp.person.name.formatted, 'forward');
  });

}).call(this);
