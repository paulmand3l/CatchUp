(function() {
  var FREQUENCY_SCALE, f, frequencyList, period, _i, _len, _ref;

  FREQUENCY_SCALE = [];

  _ref = {
    week: [1, 2, 3],
    month: [1, 2, 3, 4, 6, 8],
    year: [1]
  };
  for (period in _ref) {
    frequencyList = _ref[period];
    for (_i = 0, _len = frequencyList.length; _i < _len; _i++) {
      f = frequencyList[_i];
      FREQUENCY_SCALE.push([f, period]);
    }
  }

  angular.module("CatchUp", ["ionic", "ngCordova", "ui.slider"]).run(function($ionicPlatform) {
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
  }).controller('HomeCtrl', function($scope, $location, CatchUps, $cordovaContacts) {
    $scope.catchUps = CatchUps.all();
    if ($scope.catchUps.length < 1) {
      $scope.catchUps.push({
        person: {
          name: {
            formatted: "Add a catchup"
          }
        },
        frequency: 1,
        period: 'month'
      });
    }
    CatchUps.save($scope.catchUps);
    return $scope.pickContact = function() {
      return $cordovaContacts.pickContact().then(function(contact) {
        var duplicate, newCatchUp, newLength;
        newCatchUp = CatchUps.newCatchUp(contact);
        duplicate = $scope.catchUps.some(function(catchUp) {
          return catchUp.person.name.formatted === newCatchUp.person.name.formatted;
        });
        if (!duplicate) {
          newLength = $scope.catchUps.push(newCatchUp);
          CatchUps.save($scope.catchUps);
          return $location.path('/edit/' + (newLength - 1));
        }
      });
    };
  }).controller('EditCtrl', function($scope, CatchUps, $stateParams, $ionicNavBarDelegate) {
    $scope.catchUp = CatchUps.get($stateParams.catchUpId);
    $scope.FREQUENCY_SCALE = FREQUENCY_SCALE;
    return $ionicNavBarDelegate.changeTitle($scope.catchUp.person.name.formatted, 'forward');
  });

}).call(this);
