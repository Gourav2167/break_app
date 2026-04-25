import Flutter
import UIKit
import DeviceActivity
import FamilyControls

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "com.haveabreak/usage"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let usageChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        
        usageChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "requestPermission":
                self?.requestScreenTimePermission(result: result)
            case "startMonitoring":
                self?.startDeviceActivityMonitoring()
                result(true)
            case "getUsageData":
                result(self?.getSharedUsageData())
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func requestScreenTimePermission(result: @escaping FlutterResult) {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                    result(true)
                } catch {
                    result(false)
                }
            }
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Screen Time API requires iOS 15+", details: nil))
        }
    }
    
    private func startDeviceActivityMonitoring() {
        if #available(iOS 15.0, *) {
            // Logic to configure DeviceActivityCenter with specific schedules
            // and app tokens selected via FamilyActivityPicker
        }
    }
    
    private func getSharedUsageData() -> [String: Int]? {
        let sharedDefaults = UserDefaults(suiteName: "group.com.haveabreak.shared")
        // Return the logs map directly to Flutter
        return sharedDefaults?.dictionary(forKey: "usageLogs") as? [String: Int]
    }
}
