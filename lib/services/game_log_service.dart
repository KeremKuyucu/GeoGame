// lib/services/game_log_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geogame/models/app_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/services/auth_service.dart';

class GameLogService {
  static final _supabase = Supabase.instance.client;
  static const String _unsentLogsKey = 'unsent_game_logs';

  static Future<void> saveToStorage(String gameType) async {
    if (AppState.session.totalScore == 0 && AppState.session.wrongCount == 0) return;

    if (!AuthService.isAuthenticated) {
      debugPrint("🚫 Misafir kullanıcı: Skor kaydedilmedi ve kuyruğa alınmadı.");
      return;
    }

    await GameLogService.queueSessionLocal(
      sessionId: AppState.session.sessionId,
      gameType: gameType,
      correctCount: AppState.session.correctCount,
      wrongCount: AppState.session.wrongCount,
      scoreEarned: AppState.session.totalScore,
    );
  }


  /// 📝 Oyunu yerel kuyruğa ekler veya günceller
  static Future<void> queueSessionLocal({
    required String sessionId,
    required String gameType,
    required int correctCount,
    required int wrongCount,
    required int scoreEarned,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> unsentList = prefs.getStringList(_unsentLogsKey) ?? [];

      unsentList.removeWhere((item) {
        try {
          final map = jsonDecode(item);
          return map['id'] == sessionId;
        } catch (e) {
          return false;
        }
      });

      Map<String, dynamic> sessionLog = {
        'id': sessionId,
        'gameType': gameType,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'scoreEarned': scoreEarned,
        'played_at': DateTime.now().toIso8601String(),
      };

      unsentList.add(jsonEncode(sessionLog));
      await prefs.setStringList(_unsentLogsKey, unsentList);

    } catch (e) {
      debugPrint('❌ Log Kuyruklama Hatası: $e');
    }
  }

  static Future<void> syncPendingLogs() async {
    // Auth kontrolü: Kullanıcı yoksa gönderme
    if (!AuthService.isAuthenticated) return;

    // Senin mantığına göre ID kesin var
    final uid = AuthService.currentUserId!;

    final prefs = await SharedPreferences.getInstance();
    List<String> unsentList = prefs.getStringList(_unsentLogsKey) ?? [];

    if (unsentList.isEmpty) return;

    debugPrint("🔄 Sync Başlatıldı: ${unsentList.length} oyun gönderiliyor...");

    try {
      List<Map<String, dynamic>> bulkInsertData = [];

      for (String jsonLog in unsentList) {
        final logData = jsonDecode(jsonLog);
        bulkInsertData.add({
          'user_id': uid,
          'game_type': logData['gameType'],
          'correctCount': logData['correctCount'],
          'wrongCount': logData['wrongCount'],
          'scoreEarned': logData['scoreEarned'],
          'played_at': logData['played_at'],
        });
      }

      // Supabase toplu insert
      await _supabase.from('game_logs').insert(bulkInsertData);

      // Başarılıysa kuyruğu temizle
      await prefs.setStringList(_unsentLogsKey, []);
      debugPrint("✅ Sync Başarılı: Kuyruk temizlendi.");

    } catch (e) {
      debugPrint("❌ Sync Hatası: $e");
      // Hata durumunda kuyruk silinmez, sonraki denemede tekrar gönderilir.
    }
  }
}