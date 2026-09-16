import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/services/telemetry_service.dart';
import 'package:uuid/uuid.dart';

import 'package:geogame/services/auth_service.dart';

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

  /// Oyun başladığında çağrılabilir.
  static String startNewSession() {
    return _uuid.v4();
  }

  /// Her doğru cevapta çağrılır.
  static Future<void> logQuestion({
    required String gameType,
    required String correctAnswer,
    required List<dynamic> options,
    required int wrongCount,
    required int scoreEarned,
    DateTime? questionStartTime,
  }) async {
    if (!AuthService.isAuthenticated) return;

    final startTime = questionStartTime ?? _session.currentQuestionStartTime;

    // Sadece benzersiz kayıt ID'si.
    final questionId = _uuid.v4();

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

    final rawList = prefs.getStringList(_unsentLogsKey) ?? <String>[];

    rawList.add(jsonEncode(log));

    await prefs.setStringList(_unsentLogsKey, rawList);
  }

  /// Ana menüye dönünce / oyun bitince çağrılır.
  static Future<void> syncPendingLogs() async {
    if (!AuthService.isAuthenticated) return;

    final uid = AuthService.currentUserId!;
    final prefs = await SharedPreferences.getInstance();

    final rawList = prefs.getStringList(_unsentLogsKey) ?? <String>[];

    if (rawList.isEmpty) return;

    debugPrint(
      '🔄 Sync: ${rawList.length} question log gönderiliyor',
    );

    for (final item in rawList) {
      final log = jsonDecode(item) as Map<String, dynamic>;

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
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          // Kayıt zaten varsa başarılı kabul et.
          continue;
        }

        // Gerçek hata → queue korunur.
        debugPrint(
          '❌ Question log sync hatası: $e',
        );
        return;
      } catch (e, stack) {
        // Ağ vb. hata → queue korunur.
        debugPrint(
          '❌ Question log sync hatası: $e',
        );
        TelemetryService.sendError(
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

    // Bütün kayıtlar başarıyla gönderildiyse queue temizlenir.
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

  int currentQuestionWrongCount = 0;
  DateTime currentQuestionStartTime = DateTime.now().toUtc();

  int lastQuestionScoreEarned = 0;
  int lastQuestionWrongCount = 0;

  void reset({
    required int startScore,
    required int minScore,
    int? maxWrongPenalty,
  }) {
    totalScore = 0;
    correctCount = 0;
    wrongCount = 0;
    passCount = 0;

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

    final proportional = (_startScore * 0.2).round();

    final cap = _maxWrongPenalty ?? _startScore;

    final penalty = proportional.clamp(1, cap);

    currentQuestionScore -= penalty;

    if (currentQuestionScore < _minScore) {
      currentQuestionScore = _minScore;
    }
  }

  void submitPass() {
    passCount++;

    lastQuestionScoreEarned = 0;
    lastQuestionWrongCount = currentQuestionWrongCount;

    currentQuestionScore = _startScore;
  }
}
