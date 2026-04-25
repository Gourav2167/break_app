import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:have_a_break/core/models/usage_model.dart';
import 'db_service.dart';

// We'll use a manual Notifier for now to avoid build_runner dependency if it's not setup.
class SessionTrackingNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void updateSession(String pkg, int duration) {
    state = {...state, pkg: duration};
  }
}

final sessionTrackingProvider = NotifierProvider<SessionTrackingNotifier, Map<String, int>>(SessionTrackingNotifier.new);

final usageTrackerProvider = FutureProvider.autoDispose<List<UsageModel>>((ref) async {
  const channel = MethodChannel('com.haveabreak/usage');
  final dbService = DBService();

  // 1. Handle real-time high-precision updates from the native heartbeat
  channel.setMethodCallHandler((call) async {
    if (call.method == 'onUsageData') {
      final data = call.arguments as Map;
      final pkg = data['packageName'] as String?;
      final duration = (data['sessionDuration'] as num?)?.toInt() ?? 0;
      
      if (pkg != null) {
        ref.read(sessionTrackingProvider.notifier).updateSession(pkg, duration);
      }
    }
  });

  // 2. Fetch "Ground Truth" persistent baseline
  final List<UsageModel> result = [];
  
  try {
    if (Platform.isAndroid) {
      // On Android, we rely on our persistent SQLite store for survival
      final persistentLogs = await dbService.getAllUsage();
      result.addAll(persistentLogs);
    } else if (Platform.isIOS) {
      // On iOS, we read from the App Group shared UserDefaults
      final Map? sharedLogs = await channel.invokeMethod('getSharedUsageData');
      if (sharedLogs != null) {
        sharedLogs.forEach((pkg, duration) {
          result.add(UsageModel(
            appName: pkg.toString().split('.').last.toUpperCase(), // Basic name fallback
            packageName: pkg.toString(),
            durationSeconds: duration as int,
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  } catch (e) {
    print('[usage_provider] ⚠️ Native fetch failed, falling back to system API: $e');
    // Fallback to system API if native store fails
    try {
      final List<dynamic>? stats = await channel.invokeMethod('getUsageStats');
      if (stats != null) {
        result.addAll(stats.map((item) => UsageModel.fromMap(Map<String, dynamic>.from(item))));
      }
    } catch (innerE) {
      print('[usage_provider] ❌ Critical failure: $innerE');
    }
  }

  // 3. Combine persistent data with real-time session delta
  final activeSessions = ref.watch(sessionTrackingProvider);
  
  final Map<String, UsageModel> combined = {};
  for (var item in result) {
    final currentSessionDelta = activeSessions[item.packageName] ?? 0;
    combined[item.packageName] = UsageModel(
      appName: item.appName,
      packageName: item.packageName,
      durationSeconds: item.durationSeconds + currentSessionDelta,
      timestamp: item.timestamp,
    );
  }

  final finalResult = combined.values.toList();

  // 4. Sort by usage (User Requirement: most used at top)
  finalResult.sort((a, b) => b.durationSeconds.compareTo(a.durationSeconds));

  return finalResult;
});

final usageActionsProvider = Provider.autoDispose<UsageActions>((ref) {
  return UsageActions();
});

class UsageActions {
  final _channel = const MethodChannel('com.haveabreak/usage');

  Future<void> startTracking() async {
    await _channel.invokeMethod('startService');
  }

  Future<void> stopTracking() async {
    await _channel.invokeMethod('stopService');
  }

  Future<bool> checkPermission() async {
    return await _channel.invokeMethod('checkPermission') ?? false;
  }

  Future<void> requestPermission() async {
    await _channel.invokeMethod('requestPermission');
  }
}
