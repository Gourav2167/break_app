import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:have_a_break/core/services/db_service.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final DBService _dbService = DBService();

  Future<void> syncData() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final logs = await _dbService.getAllUsage();
    if (logs.isEmpty) return;

    try {
      final List<Map<String, dynamic>> dataToSync = logs.map((log) {
        final map = log.toMap();
        map['user_id'] = user.id;
        return map;
      }).toList();

      await _client.from('usage_logs').upsert(dataToSync);
      // Optional: Clear local logs after successful sync if sync is strictly one-way
      // await _dbService.clearLogs();
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
