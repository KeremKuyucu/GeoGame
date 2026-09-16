import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/telemetry_service.dart';

class GameLogService {
  static final _supabase = Supabase.instance.client;
  static const String _unsentLogsKey = 'question_logs';
  static const _uuid = Uuid();
  static final _session = GameSession();

  static int get totalScore => _session.totalScore;
  static int get correctCount => _session.correctCount;
  static int get wrongCount => _session.wrongCount;
  static int get currentQuestionScore => _session.currentQuestionScore;
  static int get currentQuestionWrongCount =>
      _session.currentQuestionWrongCount;
  static DateTime get currentQuestionStartTime =>
      _session.currentQuestionStartTime;
  static int get lastQuestionScoreEarned => _session.lastQuestionScoreEarned;
  static int get lastQuestionWrongCount => _session.lastQuestionWrongCount;

  static void resetSession({
    required int startScore,
    required int minScore,
    int? maxWrongPenalty,
  }) =>
      _session.reset(
        startScore: startScore,
        minScore: minScore,
        maxWrongPenalty: maxWrongPenalty,
      );

  static void startNewQuestion() => _session.startNewQuestion();
  static void submitCorrect() => _session.submitCorrect();
  static void submitWrong() => _session.submitWrong();
  static void submitPass() => _session.submitPass();
  static void addWrongAnswers(int count) => _session.wrongCount += count;

  /// 🎮 Oyun başladığında ÇAĞRILACAK
  /// Tek bir oyun için tek bir log id üretir
  static String startNewSession() {
    return _uuid.v4();
  }

  /// Zaman ve sorudan özel seed oluşturup UUIDv5 üretir
  static String generateQuestionId({
    required String question,
    required DateTime timestamp,
    required String gameType,
  }) {
    final seed =
        '${AuthService.currentUserId}_${gameType}_${question}_${timestamp.millisecondsSinceEpoch}';

    return _uuid.v5(
      Namespace.url.value,
      seed,
    );
  }

  /// ❓ Her soru doğru bilindiğinde çağrılır.
  /// [correctAnswer] hedef ülkenin ISO3 kodudur (örn. 'TUR').
  static Future<void> logQuestion({
    required String gameType,
    required String correctAnswer,
    required List<dynamic> options,
    required int wrongCount,
    required int scoreEarned,
    DateTime? questionStartTime,
  }) async {
    if (!AuthService.isAuthenticated) return;

    try {
      final startTime = questionStartTime ?? _session.currentQuestionStartTime;
      final questionId = generateQuestionId(
        question: correctAnswer,
        timestamp: startTime,
        gameType: gameType,
      );

      final log = {
        'game_type': gameType,
        'question_id': questionId,
        'options': options,
        'correct_answer': correctAnswer,
        'wrong_count': wrongCount,
        'score_earned': scoreEarned,
        'played_at': startTime.toIso8601String(),
      };

      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_unsentLogsKey) ?? [];
      rawList.add(jsonEncode(log));
      await prefs.setStringList(_unsentLogsKey, rawList);
    } catch (e, stack) {
      debugPrint('❌ logQuestion hatası: $e');
      await TelemetryService.sendError(
        event: 'log_question_error',
        message: e.toString(),
        stackTrace: stack,
        metadata: {
          'game_type': gameType,
          'correct_answer': correctAnswer,
        },
      );
    }
  }

  /// Geriye dönük uyumluluk
  @Deprecated('Use logQuestion instead')
  static Future<void> saveProgress(String gameType) async {}

  /// 🏁 Ana menüye dönünce / oyun bitince çağrılır
  /// Kuyruktaki tüm logları 'question_logs' tablosuna yollar
  static Future<void> syncPendingLogs() async {
    if (!AuthService.isAuthenticated) return;

    final uid = AuthService.currentUserId!;
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_unsentLogsKey) ?? [];

    if (rawList.isEmpty) return;

    debugPrint('🔄 Sync: ${rawList.length} question log gönderiliyor');

    for (final item in rawList) {
      final log = jsonDecode(item);

      final payload = {
        'user_id': uid,
        'game_type': log['game_type'],
        'question_id': log['question_id'],
        'options': log['options'],
        'correct_answer': log['correct_answer'],
        'wrong_count': log['wrong_count'],
        'score_earned': log['score_earned'],
        'played_at': log['played_at'],
      };

      try {
        await _supabase.from('question_logs').insert(payload);
      } on PostgrestException catch (e, stack) {
        if (e.code == '23505') {
          // Zaten DB'de var → bu kaydı başarılı kabul et
          continue;
        }

        // Gerçek Postgrest hatası → queue korunur ve Discord'a bildirilir
        debugPrint('❌ Question log sync hatası: $e');
        await TelemetryService.sendError(
          event: 'question_log_postgrest_error',
          message: 'PostgrestException (${e.code}): ${e.message}',
          stackTrace: stack,
          metadata: {
            'code': e.code,
            'details': e.details,
            'hint': e.hint,
            'game_type': log['game_type'],
            'question_id': log['question_id'],
          },
        );
        return;
      } catch (e, stack) {
        // Ağ vb. genel hata → queue korunur ve Discord'a bildirilir
        debugPrint('❌ Question log sync hatası: $e');
        await TelemetryService.sendError(
          event: 'question_log_sync_error',
          message: e.toString(),
          stackTrace: stack,
          metadata: {
            'game_type': log['game_type'],
            'question_id': log['question_id'],
            'options': log['options'],
            'correct_answer': log['correct_answer'],
            'wrong_count': log['wrong_count'],
            'score_earned': log['score_earned'],
            'played_at': log['played_at'],
          },
        );
        return;
      }
    }

    await prefs.remove(_unsentLogsKey);
    debugPrint('✅ Question logs sync tamamlandı');
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
  int? _maxWrongPenalty;
  int currentQuestionScore = 50;

  // Soru bazlı takip
  int currentQuestionWrongCount = 0;
  DateTime currentQuestionStartTime = DateTime.now().toUtc();
  int lastQuestionScoreEarned = 0;
  int lastQuestionWrongCount = 0;

  void reset({
    required int startScore,
    required int minScore,
    int? maxWrongPenalty,
  }) {
    totalScore = correctCount = wrongCount = passCount = 0;
    sessionId = const Uuid().v4();
    _startScore = startScore;
    _minScore = minScore;
    _maxWrongPenalty = maxWrongPenalty;
    currentQuestionScore = _startScore;
    startNewQuestion();
  }

  void startNewQuestion() {
    currentQuestionWrongCount = 0;
    currentQuestionStartTime = DateTime.now().toUtc();
    currentQuestionScore = _startScore;
  }

  void submitCorrect() {
    correctCount++;
    lastQuestionScoreEarned = currentQuestionScore;
    lastQuestionWrongCount = currentQuestionWrongCount;
    totalScore += currentQuestionScore;
    currentQuestionScore = _startScore;
  }

  void submitWrong() {
    wrongCount++;
    currentQuestionWrongCount++;
    // Ceza, başlangıç skoruyla orantılı (%20), en az 1 puan, isteğe bağlı max tavan ile sınırlı
    final proportional = (_startScore * 0.2).round();
    final cap = _maxWrongPenalty ?? _startScore;
    final penalty = proportional.clamp(1, cap);
    currentQuestionScore -= penalty;
    if (currentQuestionScore < _minScore) currentQuestionScore = _minScore;
  }

  void submitPass() {
    passCount++;
    lastQuestionScoreEarned = 0;
    lastQuestionWrongCount = currentQuestionWrongCount;
    currentQuestionScore = _startScore;
  }
}
