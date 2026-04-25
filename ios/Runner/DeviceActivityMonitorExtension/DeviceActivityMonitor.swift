import DeviceActivity
import Foundation
import FamilyControls

// The DeviceActivityMonitor allows the system to notify your extension of changes in device activity.
@available(iOS 15.0, *)
class DeviceActivityMonitor: DeviceActivityMonitorExtension {
    let sharedDefaults = UserDefaults(suiteName: "group.com.haveabreak.shared")
    
    // Called when the activity threshold is reached (e.g., every 1 second of usage)
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Log the end of an interval if needed
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // This is where we update local "Ground Truth"
        // We use the event name to identify the app/category
        let packageName = event.rawValue
        updateUsage(for: packageName)
    }
    
    private func updateUsage(for packageName: String) {
        var logs = sharedDefaults?.dictionary(forKey: "usageLogs") as? [String: Int] ?? [:]
        let currentDuration = logs[packageName] ?? 0
        logs[packageName] = currentDuration + 1 // Increment by 1 second (or interval)
        
        sharedDefaults?.set(logs, forKey: "usageLogs")
        sharedDefaults?.synchronize()
    }
}
