import DeviceActivity
import Foundation

// Note: This must be part of a DeviceActivityMonitorExtension target in Xcode
class DeviceActivityMonitor: DeviceActivityMonitorExtension {
    let sharedDefaults = UserDefaults(suiteName: "group.com.haveabreak.shared")

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        logUsage(appName: activity.rawValue, event: "started")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        logUsage(appName: activity.rawValue, event: "ended")
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        logUsage(appName: activity.rawValue, event: "thresholdReached")
    }
    
    private func logUsage(appName: String, event: String) {
        var logs = sharedDefaults?.dictionary(forKey: "usageLogs") ?? [:]
        let timestamp = ISO8601DateFormatter().string(from: Date())
        logs[timestamp] = ["app": appName, "event": event]
        
        sharedDefaults?.set(logs, forKey: "usageLogs")
        sharedDefaults?.synchronize()
    }
}
