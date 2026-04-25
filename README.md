# have_a_break 🧘‍♂️

A minimalist digital wellbeing application built with Flutter, focused on "Zen-inspired" app usage tracking and persistence.

## ✨ Features
- **Persistent Tracking**: Usage data survives app kills, restarts, and battery death.
- **Cross-Platform Architecture**: 
  - **Android**: Custom Kotlin Foreground Service with SQLite persistence.
  - **iOS**: Screen Time API integration via DeviceActivityMonitorExtension.
- **Real-time Updates**: Live dashboard counting without refresh or flicker.
- **Minimalist Design**: Deep dark mode with high-contrast typography.

## 🚀 Setup & Installation

### Android
1. **Build APK**: Run `flutter build apk --release`.
2. **Permissions**: Once installed, grant **Usage Access** in Android Settings.
3. **Optimizations**: For best results, disable battery optimization for the app to keep the foreground service active.

### iOS
1. **Requirements**: Needs a paid Apple Developer account (for Screen Time API entitlements).
2. **Capabilities**: Enable `Family Controls`, `Device Activity`, and `App Groups` in Xcode.
3. **Extension**: Register the `DeviceActivityMonitorExtension` target and associate it with the shared App Group: `group.com.haveabreak.shared`.

## 🛠️ Tech Stack
- **Framework**: Flutter
- **State Management**: Riverpod 3.0
- **Native Logic**: Kotlin (Android) / Swift (iOS)
- **Database**: SQLite (Android) / UserDefaults App Groups (iOS)
- **Backend (Optional)**: Supabase

## 📖 How it Works
For a detailed but simple explanation of the background tracking logic, see:
- [APP_TRACKING_INFO.txt](./APP_TRACKING_INFO.txt)

---
*Created with focus on presence and digital balance.*
