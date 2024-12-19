import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, BatteryApi {
    func getBatteryLevel() -> Int64 {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        UIDevice.current.isBatteryMonitoringEnabled = false
        
        if batteryLevel < 0 {
            return -1
        }
        
        return Int64(batteryLevel * 100)
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        BatteryApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: self)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
