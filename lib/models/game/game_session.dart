import 'package:uuid/uuid.dart';
import 'package:geogame/services/bonus_service.dart';

/// Soru tamamlandığında dönen sonuç modeli
class QuestionResult {
  final int scoreEarned;
  final int wrongCount;
  final DateTime startTime;

  const QuestionResult({
    required this.scoreEarned,
    required this.wrongCount,
    required this.startTime,
  });
}

/// Oyun oturumu boyunca skor, soru bazlı puan ve sayaçları yöneten model
class GameSession {
  static final GameSession current = GameSession();

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

  /// Yanlış cevap verildiğinde çağrılır:
  /// Bu soru için yanlış sayısını artırır, ceza puanını düşer ve oturum geneli yanlışı artırır.
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

  /// Doğru cevap verildiğinde çağrılır.
  /// İsteğe bağlı [customScore] ve [customWrongCount] alabilir.
  /// Soru sonucunu [QuestionResult] olarak döndürür ve yeni soru için hazırlar.
  QuestionResult submitCorrect({int? customScore, int? customWrongCount}) {
    correctCount++;

    if (customWrongCount != null && customWrongCount > 0) {
      wrongCount += customWrongCount;
      currentQuestionWrongCount = customWrongCount;
    }

    final baseScore = customScore ?? currentQuestionScore;
    final multiplied = baseScore * BonusService.scoreMultiplier;

    lastQuestionScoreEarned = multiplied;
    lastQuestionWrongCount = currentQuestionWrongCount;

    totalScore += multiplied;

    final result = QuestionResult(
      scoreEarned: multiplied,
      wrongCount: currentQuestionWrongCount,
      startTime: currentQuestionStartTime,
    );

    currentQuestionScore = _startScore;
    return result;
  }

  QuestionResult submitPass() {
    passCount++;
    lastQuestionScoreEarned = 0;
    lastQuestionWrongCount = currentQuestionWrongCount;

    final result = QuestionResult(
      scoreEarned: 0,
      wrongCount: currentQuestionWrongCount,
      startTime: currentQuestionStartTime,
    );

    currentQuestionScore = _startScore;
    return result;
  }
}
