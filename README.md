#LiteServ-iOS

LiteServ-iOS is a LiteServ app that runs on iOS or tvOS devices.

##How to build and run?

###Requirement
- XCode 8

###Get the code
 ```
 $git clone https://github.com/couchbaselabs/liteserv-ios.git
 $git submodule update --init
 ```
 
###Install frameworks
Copy couchbase-lite-ios framework files into [Frameworks/iOS](https://github.com/couchbaselabs/liteserv-ios/tree/master/Frameworks/iOS) and [Frameworks/tvOS](https://github.com/couchbaselabs/liteserv-ios/tree/master/Frameworks/tvOS) directory. See the README file in those folders for more detail about what files to copy.

###Build and run with XCode
1. Open LiteServ-iOS project with XCode.
2. Select `LiteServ-iOS` scheme to run on iOS devices.
3. Or select `LiteServ-tvOS` scheme to run on tvOS devices.
4. If you want the App to build with SQLCipher instead of SQLite, select the scheme that ends with `-SQLCipher`.

###Build and run with command lines (Simulator only)
1. Build the app:

 iOS:
 ```
 $xcodebuild -scheme LiteServ-iOS -sdk iphonesimulator -configuration Release -derivedDataPath build
 ```
 tvOS:
 ```
 $xcodebuild -scheme LiteServ-tvOS -sdk iphonesimulator -configuration Release -derivedDataPath build
 ```
 To build with SQLCipher, use `-scheme LiteServ-iOS-SQLCipher` for iOS and `-scheme LiteServ-tvOS-SQLCipher` for tvOS.

2. Run the simulator:
 ```
 $killall Simulator
 $open -a Simulator --args -CurrentDeviceUDID <YOUR SIMULATOR UUID>
 ```
 To find the simulator UUID, use one of the following commands:
 ```
 $instruments -s devices
 $xcrun simctl list
 ```

 To wait for the simulator to boot, you can write a bash script like this:
 ```
 count=`xcrun simctl list | grep Booted | wc -l | sed -e 's/ //g'`
 while [ $count -lt 1 ]
 do
 	sleep 1
	 count=`xcrun simctl list | grep Booted | wc -l | sed -e 's/ //g'`
 done
 ```
3. Install and run the app on the simulator:
 ```
 $xcrun simctl uninstall booted com.couchbase.LiteServ-iOS
 $xcrun simctl install booted <PATH to LiteServ-iOS.app>
 $xcrun simctl launch booted com.couchbase.LiteServ-iOS
 ```
 Note: tvOS app file name will be `LiteServe-tvOS.app`. If buidling the app with SQLCipher, the app file name will be `LiteServ-iOS-SQLCipher.app` for iOS and `LiteServ-tvOS-SQLCipher.app` for tvOS.

 Reference: https://coderwall.com/p/fprm_g/chose-ios-simulator-via-command-line--2 (Note: Some of the commands may be old.)

##How to change default settings?
Before running the app, you can setup environment variables to set the app settings. The app settings consist of:

Name       | Default value| Description|
-----------|--------------|------------|
adminPort  |59850         |Admin port to listen on
port       |49850         |Listener port to listen on
readonly   |false         |Enables read-only mode
revsLimit  |0             |Sets default max rev-tree depth for database (0 = using CBL default value)
storage    |SQLite        |Set default storage engine: 'SQLite' or 'ForestDB'
dbpasswords|Empty value   |Register passwords to open a database. Format: db1=pass1,db2=pass2,..
ssl			 |false         |Serve over SSL with the identity name as 'LiteServ'

If running the app with XCode, you can select `Edit Scheme...` of the scheme you want to run and then setup your environment variables from there. If running the app by using the `xcrun` command, you can set the environment variables by using export command and prefix each variable with the `SIMCTL_CHILD_` as below:

```
export SIMCTL_CHILD_port="8888"
export SIMCTL_CHILD_dbpasswords="db1=seekrit1,db2=seekrit2"
```

##How to use Admin port?
1. `PUT /start` : Start or restart the listener with JSON configuration.

 ```
$curl -X PUT -H "Content-Type: application/json" -d '{
    "port": 8888,
    "dbpasswords": "db1=seekrit1,db2=seekrit2"
}' "http://localhost:59850/start"
 ```
 
2. `PUT /stop` : Stop the listener.
 ```
 $curl -X PUT "http://localhost:59850/stop"
 ```
 
3. `GET /` See current running:
 ```
 $curl -X GET "http://localhost:59850/"
 ```
