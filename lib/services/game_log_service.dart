import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';

class GameLogService {
  static final _supabase = Supabase.instance.client;
  static const String _unsentLogsKey = 'game_logs';
  static const _uuid = Uuid();

  /// 🎮 Oyun başladığında ÇAĞRILACAK
  /// Tek bir oyun için tek bir log id üretir
  static String startNewSession() {
    return _uuid.v4();
  }

  /// ❓ Her sorudan sonra çağrılır
  /// Aynı sessionId ile yerelde GÜNCELLER
  static Future<void> saveProgress(String gameType) async {
    if (!AuthService.isAuthenticated) return;

    final session = AppState.session;

    if (session.sessionId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList =
        prefs.getStringList(_unsentLogsKey) ?? [];

    Map<String, dynamic>? existing;

    rawList.removeWhere((item) {
      final map = jsonDecode(item);
      if (map['id'] == session.sessionId) {
        existing = map;
        return true;
      }
      return false;
    });

    final log = {
      'id': session.sessionId, // UUID
      'gameType': gameType,
      'correctCount': session.correctCount,
      'wrongCount': session.wrongCount,
      'scoreEarned': session.totalScore,
      'played_at': existing?['played_at'] ??
          DateTime.now().toUtc().toIso8601String(),
    };

    rawList.add(jsonEncode(log));
    await prefs.setStringList(_unsentLogsKey, rawList);
  }


  /// 🏁 Ana menüye dönünce / oyun bitince çağrılır
  /// Kuyruktaki tüm logları server’a yollar
  static Future<void> syncPendingLogs() async {
    if (!AuthService.isAuthenticated) return;

    final uid = AuthService.currentUserId!;
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList =
        prefs.getStringList(_unsentLogsKey) ?? [];

    if (rawList.isEmpty) return;

    debugPrint("🔄 Sync: ${rawList.length} log gönderiliyor");

    final List<Map<String, dynamic>> payload = [];

    for (final item in rawList) {
      final log = jsonDecode(item);
      payload.add({
        'user_id': uid,
        'client_log_id': log['id'], // UUID
        'game_type': log['gameType'],
        'correctCount': log['correctCount'],
        'wrongCount': log['wrongCount'],
        'scoreEarned': log['scoreEarned'],
        'played_at': log['played_at'],
      });
    }

    try {
      await _supabase.from('game_logs').upsert(
        payload,
        onConflict: 'user_id,client_log_id',
        ignoreDuplicates: true,
      );

      // ❗ başarılıysa kuyruk temizlenir
      await prefs.remove(_unsentLogsKey);
      debugPrint("✅ Sync tamamlandı");

    } catch (e) {
      // ❗ duplicate varsa DB reddeder ama kuyruk KALIR
      debugPrint("❌ Sync hatası (tekrar denenecek): $e");
    }
  }
}
