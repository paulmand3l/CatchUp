CatchUp
=======

iPhone app to keep track of when to catch up with your friends.

    npm install -g cordova ionic ios-sim
    ionic platform add ios
    cordova plugin add org.apache.cordova.contacts

You'll need to manually copy the contents of the /www/img/splash folder into /platforms/ios/CatchUp/Resources/splash/.  Overwrite all contents.

    gulp watch
    ionic emulate ios
