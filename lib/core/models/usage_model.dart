class UsageModel {
  final int? id;
  final String appName;
  final String packageName;
  final int durationSeconds;
  final DateTime timestamp;

  UsageModel({
    this.id,
    required this.appName,
    required this.packageName,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'app_name': appName,
      'package_name': packageName,
      'duration_seconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UsageModel.fromMap(Map<String, dynamic> map) {
    return UsageModel(
      id: map['id'],
      appName: map['app_name'],
      packageName: map['package_name'],
      durationSeconds: map['duration_seconds'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
