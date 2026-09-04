import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:geogame/services/auth_service.dart';

class GameLogService {
  static final _supabase = Supabase.instance.client;
  static const String _unsentLogsKey = 'game_logs';
  static const _uuid = Uuid();
  static final _session = GameSession();

  static int get totalScore => _session.totalScore;
  static int get correctCount => _session.correctCount;
  static int get wrongCount => _session.wrongCount;
  static void resetSession({required int startScore, required int minScore}) =>
      _session.reset(startScore: startScore, minScore: minScore);
  static void submitCorrect() => _session.submitCorrect();
  static void submitWrong() => _session.submitWrong();
  static void submitPass() => _session.submitPass();
  static void addWrongAnswers(int count) => _session.wrongCount += count;

  /// 🎮 Oyun başladığında ÇAĞRILACAK
  /// Tek bir oyun için tek bir log id üretir
  static String startNewSession() {
    return _uuid.v4();
  }

  /// ❓ Her sorudan sonra çağrılır
  /// Aynı sessionId ile yerelde GÜNCELLER
  static Future<void> saveProgress(String gameType) async {
    if (!AuthService.isAuthenticated) return;

    final session = _session;

    if (session.sessionId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_unsentLogsKey) ?? [];

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
      'played_at':
          existing?['played_at'] ?? DateTime.now().toUtc().toIso8601String(),
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
    final List<String> rawList = prefs.getStringList(_unsentLogsKey) ?? [];

    if (rawList.isEmpty) return;

    debugPrint('🔄 Sync: ${rawList.length} log gönderiliyor');

    final List<Map<String, dynamic>> payload = [];

    for (final item in rawList) {
      final log = jsonDecode(item);
      payload.add({
        'user_id': uid,
        'client_log_id': log['id'], // UUID
        'game_type': log['gameType'],
        'correct_count': log['correctCount'],
        'wrong_count': log['wrongCount'],
        'score_earned': log['scoreEarned'],
        'played_at': log['played_at'],
      });
    }

    try {
      await _supabase.from('game_logs').insert(
            payload,
          );

      // ❗ başarılıysa kuyruk temizlenir
      await prefs.remove(_unsentLogsKey);
      debugPrint('✅ Sync tamamlandı');
    } catch (e) {
      // ❗ duplicate varsa DB reddeder ama kuyruk KALIR
      debugPrint('❌ Sync hatası (tekrar denenecek): $e');
    }
  }
}

class GameSession {
  int totalScore = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int passCount = 0;
  String sessionId = '';
  int _startScore = 50;
  int _minScore = 20;
  int currentQuestionScore = 50;

  void reset({required int startScore, required int minScore}) {
    totalScore = correctCount = wrongCount = passCount = 0;
    sessionId = const Uuid().v4();
    _startScore = startScore;
    _minScore = minScore;
    currentQuestionScore = _startScore;
  }

  void submitCorrect() {
    correctCount++;
    totalScore += currentQuestionScore;
    currentQuestionScore = _startScore;
  }

  void submitWrong() {
    wrongCount++;
    currentQuestionScore -= 10;
    if (currentQuestionScore < _minScore) currentQuestionScore = _minScore;
  }

  void submitPass() {
    passCount++;
    currentQuestionScore = _startScore;
  }
}
