# Have A Break - Usage Tracking Architecture

This document explains how the application tracks app usage across Android and iOS platforms, ensuring data persistence and background reliability.

## 1. Central Philosophy: "Native Ground Truth"
The Flutter app does not calculate usage time itself. Instead, it acts as a viewer for "Ground Truth" data collected and persisted by native system services. This ensures that tracking continues even if the app is killed by the OS.

---

## 2. Android Implementation (Foreground Service)

Android allows apps to query `UsageStatsManager` to see what is currently running.

### How it works:
1.  **UsageService (Kotlin)**: A `Foreground Service` is started. This keeps the app process alive with a persistent notification (required by Android for background work).
2.  **The Heartbeat**: Every 1 second, the service checks which app is in the foreground.
3.  **Local Persistence (SQLite)**: 
    - If the foreground app changes or a session continues, the duration is logged to a local SQLite database (`usage_logs.db`).
    - This database is the "Source of Truth."
4.  **Flutter Bridge**: 
    - When the Flutter UI is open, the service sends real-time updates via a `MethodChannel` (`onUsageData`).
    - On cold boot, Flutter queries the SQLite database directly to recover all historical data.

---

## 3. iOS Implementation (DeviceActivityMonitor)

iOS is much more restrictive. You cannot run a background "heartbeat" like Android. Instead, you must use Apple's **Screen Time API**.

### How it works:
1.  **DeviceActivityMonitorExtension**: This is a separate, tiny program (Extension) that iOS manages. It lives outside the main app.
2.  **The Event Trigger**: 
    - The main app requests a "Schedule" from iOS.
    - When a user opens an app that has been "selected," iOS triggers the Extension's code automatically.
3.  **Shared Persistence (App Groups)**:
    - Extensions cannot access the main app's local files. 
    - We use an **App Group** (`group.com.haveabreak.shared`) which creates a shared folder (`UserDefaults`) that both the main app and the extension can read/write to.
4.  **Flutter Bridge**: 
    - When the Flutter app starts, it asks the native iOS code to read the `usageLogs` from the shared `UserDefaults`.
    - This data is then displayed on the dashboard.

---

## 4. Cross-Platform Data Flow (Flutter)

In `usage_provider.dart`, the logic is unified:

1.  **IDENTIFY PLATFORM**: Check if the device is Android or iOS.
2.  **COLLECT BASELINE**:
    - **Android**: Load historical logs from SQLite.
    - **iOS**: Load logs from shared `UserDefaults`.
3.  **LIVE UPDATES**: Add the current active session time (received via MethodChannel) to the baseline.
4.  **SORT**: Rank apps by duration (Most Used at the top).

---

## 5. Technical Requirements for Deployment

### Android:
- Needs `PACKAGE_USAGE_STATS` permission (User must enable this in Settings).
- Needs `FOREGROUND_SERVICE` permission.

### iOS:
- **Xcode Target**: A specific "Device Activity Monitor Extension" target must be created.
- **Entitlements**: Requires a paid Apple Developer account to enable "Family Controls" and "Device Activity" capabilities.
- **App Group**: An App Group ID must be registered in the Apple Developer portal.
