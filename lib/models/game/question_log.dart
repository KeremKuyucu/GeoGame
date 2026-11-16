import 'package:uuid/uuid.dart';
import 'package:geogame/models/game/game_session.dart';

/// Her cevaplanan soruya ait log modeli
class QuestionLog {
  final String questionId;
  final String gameType;
  final String correctAnswer;
  final List<dynamic> options;
  final int wrongCount;
  final int scoreEarned;
  final DateTime playedAt;

  const QuestionLog({
    required this.questionId,
    required this.gameType,
    required this.correctAnswer,
    required this.options,
    required this.wrongCount,
    required this.scoreEarned,
    required this.playedAt,
  });

  factory QuestionLog.create({
    required String gameType,
    required String correctAnswer,
    required List<dynamic> options,
    required int wrongCount,
    required int scoreEarned,
    DateTime? playedAt,
    String? questionId,
  }) {
    return QuestionLog(
      questionId: questionId ?? const Uuid().v4(),
      gameType: gameType,
      correctAnswer: correctAnswer,
      options: options,
      wrongCount: wrongCount,
      scoreEarned: scoreEarned,
      playedAt: playedAt ?? DateTime.now().toUtc(),
    );
  }

  factory QuestionLog.fromResult({
    required String gameType,
    required String correctAnswer,
    required List<dynamic> options,
    required QuestionResult result,
    String? questionId,
  }) {
    return QuestionLog(
      questionId: questionId ?? const Uuid().v4(),
      gameType: gameType,
      correctAnswer: correctAnswer,
      options: options,
      wrongCount: result.wrongCount,
      scoreEarned: result.scoreEarned,
      playedAt: result.startTime,
    );
  }

  factory QuestionLog.fromJson(Map<String, dynamic> json) {
    return QuestionLog(
      questionId: json['question_id'] as String? ?? const Uuid().v4(),
      gameType: json['game_type'] as String? ?? '',
      correctAnswer: json['correct_answer'] as String? ?? '',
      options: (json['options'] as List<dynamic>?) ?? const [],
      wrongCount: (json['wrong_count'] as num?)?.toInt() ?? 0,
      scoreEarned: (json['score_earned'] as num?)?.toInt() ?? 0,
      playedAt: json['played_at'] != null
          ? DateTime.tryParse(json['played_at'].toString())?.toUtc() ??
              DateTime.now().toUtc()
          : DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'game_type': gameType,
        'correct_answer': correctAnswer,
        'options': options,
        'wrong_count': wrongCount,
        'score_earned': scoreEarned,
        'played_at': playedAt.toIso8601String(),
      };

  Map<String, dynamic> toSupabasePayload(String userId) => {
        'user_id': userId,
        'question_id': questionId,
        'game_type': gameType,
        'correct_answer': correctAnswer,
        'options': options,
        'wrong_count': wrongCount,
        'score_earned': scoreEarned,
        'played_at': playedAt.toIso8601String(),
      };
}
