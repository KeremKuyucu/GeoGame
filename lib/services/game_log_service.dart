import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/models/game/game_session.dart';
import 'package:geogame/models/game/question_log.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/telemetry_service.dart';

/// Soru log kuyruğunu yerelde (offline) tutan ve backend ile senkronize eden servis
abstract final class GameLogService {
  static final _supabase = Supabase.instance.client;
  static const String _unsentLogsKey = 'question_logs';

  /// Eşzamanlı okuma/yazma çakışmalarını önleyen kilit
  static Future<void> _lock = Future.value();
  static bool _isSyncing = false;

  static Future<T> _synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _lock = _lock.then((_) async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  // ---------------------------------------------------------------------------
  // GAME SESSION DELEGATES (Geriye dönük uyumluluk ve kolay erişim)
  // ---------------------------------------------------------------------------

  static GameSession get session => GameSession.current;
  static int get totalScore => GameSession.current.totalScore;
  static int get correctCount => GameSession.current.correctCount;
  static int get wrongCount => GameSession.current.wrongCount;
  static int get currentQuestionScore =>
      GameSession.current.currentQuestionScore;
  static int get currentQuestionWrongCount =>
      GameSession.current.currentQuestionWrongCount;
  static DateTime get currentQuestionStartTime =>
      GameSession.current.currentQuestionStartTime;
  static int get lastQuestionScoreEarned =>
      GameSession.current.lastQuestionScoreEarned;
  static int get lastQuestionWrongCount =>
      GameSession.current.lastQuestionWrongCount;

  static void resetSession({
    required int startScore,
    required int minScore,
    int? maxWrongPenalty,
  }) =>
      GameSession.current.reset(
        startScore: startScore,
        minScore: minScore,
        maxWrongPenalty: maxWrongPenalty,
      );

  static void startNewQuestion() => GameSession.current.startNewQuestion();
  static QuestionResult submitCorrect({
    int? customScore,
    int? customWrongCount,
  }) =>
      GameSession.current.submitCorrect(
        customScore: customScore,
        customWrongCount: customWrongCount,
      );
  static void submitWrong() => GameSession.current.submitWrong();
  static void submitPass() => GameSession.current.submitPass();

  // ---------------------------------------------------------------------------
  // QUEUE & LOGGING
  // ---------------------------------------------------------------------------

  /// Her cevaplanan soruda kuyruğa yazar.
  /// Doğrudan [QuestionResult] veya tek tek parametreleri kabul eder.
  static Future<void> logQuestion({
    required String gameType,
    required String correctAnswer,
    required List<dynamic> options,
    int? wrongCount,
    int? scoreEarned,
    DateTime? questionStartTime,
    QuestionResult? result,
  }) async {
    final finalWrongCount = result?.wrongCount ?? wrongCount ?? 0;
    final finalScoreEarned = result?.scoreEarned ?? scoreEarned ?? 0;
    final finalStartTime =
        result?.startTime ?? questionStartTime ?? DateTime.now().toUtc();

    final log = QuestionLog.create(
      gameType: gameType,
      correctAnswer: correctAnswer,
      options: options,
      wrongCount: finalWrongCount,
      scoreEarned: finalScoreEarned,
      playedAt: finalStartTime,
    );

    await _synchronized(() async {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_unsentLogsKey) ?? <String>[];
      rawList.add(jsonEncode(log.toJson()));
      await prefs.setStringList(_unsentLogsKey, rawList);
    });
  }

  /// Yerelde bekleyen (henüz senkronize edilmemiş) toplam puanı hesaplar.
  static Future<int> getPendingScore() async {
    return _synchronized(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawList = prefs.getStringList(_unsentLogsKey) ?? <String>[];
        int total = 0;
        for (final item in rawList) {
          final log = jsonDecode(item) as Map<String, dynamic>;
          total += (log['score_earned'] as num?)?.toInt() ?? 0;
        }
        return total;
      } catch (_) {
        return 0;
      }
    });
  }

  /// Yerelde bekleyen toplam soru sayısını döndürür.
  static Future<int> getPendingQuestionCount() async {
    return _synchronized(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawList = prefs.getStringList(_unsentLogsKey) ?? <String>[];
        return rawList.length;
      } catch (_) {
        return 0;
      }
    });
  }

  /// Toplu (Batch) sync: Bekleyen logları backend'e gönderir.
  /// Ağ isteği sırasında yeni soru logları eklense dahi veri kaybı oluşmaz;
  /// sadece başarıyla gönderilen ID'ler kuyruktan silinir.
  static Future<void> syncPendingLogs() async {
    if (_isSyncing) return;
    if (!AuthService.isAuthenticated) return;

    final uid = AuthService.currentUserId;
    if (uid == null) return;

    _isSyncing = true;
    try {
      // 1. Bekleyen logların güvenli anlık görüntüsünü al
      final List<QuestionLog> pendingBatch = await _synchronized(() async {
        final prefs = await SharedPreferences.getInstance();
        final rawList = prefs.getStringList(_unsentLogsKey) ?? <String>[];
        final List<QuestionLog> logs = [];
        for (final item in rawList) {
          try {
            logs.add(
                QuestionLog.fromJson(jsonDecode(item) as Map<String, dynamic>));
          } catch (e) {
            debugPrint('⚠️ Bozuk log atlandı: $e');
          }
        }
        return logs;
      });

      if (pendingBatch.isEmpty) return;

      debugPrint(
          '🔄 Sync: ${pendingBatch.length} question log toplu gönderiliyor');

      final payloadList =
          pendingBatch.map((log) => log.toSupabasePayload(uid)).toList();

      // 2. Ağ çağrısı (Supabase batch upsert)
      await _supabase
          .from('question_logs')
          .upsert(
            payloadList,
            onConflict: 'question_id',
            ignoreDuplicates: true,
          )
          .timeout(const Duration(seconds: 10));

      // 3. SADECE başarıyla gönderilen question_id'leri kuyruktan temizle
      final sentIds = pendingBatch.map((l) => l.questionId).toSet();

      await _synchronized(() async {
        final prefs = await SharedPreferences.getInstance();
        final currentRaw = prefs.getStringList(_unsentLogsKey) ?? <String>[];
        final remaining = <String>[];

        for (final item in currentRaw) {
          try {
            final data = jsonDecode(item) as Map<String, dynamic>;
            final id = data['question_id'] as String?;
            if (id == null || !sentIds.contains(id)) {
              remaining.add(item);
            }
          } catch (_) {
            // Bozuk elemanları atla
          }
        }

        if (remaining.isEmpty) {
          await prefs.remove(_unsentLogsKey);
        } else {
          await prefs.setStringList(_unsentLogsKey, remaining);
        }
      });

      debugPrint(
          '✅ Question logs sync başarıyla tamamlandı (Gönderilen: ${sentIds.length})');
    } on PostgrestException catch (e) {
      debugPrint('❌ Question log sync PostgrestException: $e');
      TelemetryService.sendError(
        event: 'question_log_sync_error',
        message: e.message,
        metadata: {'code': e.code},
      );
    } catch (e, stack) {
      debugPrint('❌ Question log sync genel hata: $e');
      TelemetryService.sendError(
        event: 'question_log_sync_error',
        message: e.toString(),
        stackTrace: stack,
      );
    } finally {
      _isSyncing = false;
    }
  }
}
