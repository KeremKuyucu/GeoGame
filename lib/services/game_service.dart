import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game/game_button.dart';
import 'package:geogame/models/game/guess_result.dart';
import 'package:geogame/models/game/border_path_data.dart';
import 'package:geogame/models/game_metadata.dart';

import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/haptic_service.dart';
import 'package:geogame/screens/settings/settings_controller.dart';

// ============================================================================
// GAME SERVICE
// ============================================================================

class GameService {
  static final math.Random _random = math.Random();
  static List<GameButton> _buttons = [];
  static final List<String> _distanceGuesses = [];

  static GameButton buttonAt(int index) => _buttons[index];
  static int get buttonCount => _buttons.length;

  static Map<String, Country>? _cachedCountryMap;
  static Map<String, Country> get _countryMap {
    if (_cachedCountryMap == null || _cachedCountryMap!.isEmpty) {
      _cachedCountryMap = {for (var c in AppState.allCountries) c.iso3: c};
    }
    return _cachedCountryMap!;
  }

  // --------------------------------------------------------------------------
  // GAME INITIALIZATION
  // --------------------------------------------------------------------------

  static Future<void> initializeGame(GameType type) async {
    final multiplier = _poolMultiplier();
    final scores = getInitialScores(type, multiplier);
    debugPrint(
        '🎯 Havuz çarpanı: ${multiplier.toStringAsFixed(2)}x '
        '(${AppState.activePool.length}/${AppState.allCountries.length} ülke) '
        '→ start=${scores['start']}, min=${scores['min']}, maxPenalty=${scores['maxPenalty']}');

    GameLogService.resetSession(
      startScore: scores['start']!,
      minScore: scores['min']!,
      maxWrongPenalty: scores['maxPenalty'],
    );

    // Cache'i temizle veya güncelle (Eğer ülke listesi değişmişse diye)
    _cachedCountryMap = null;

    if (type != GameType.borderpath) {
      await startNewRound();
    }
  }

  /// Seçilen ülke havuzunun büyüklüğüne göre bir puan çarpanı döner.
  ///
  /// Formül: multiplier = (ratio × 0.7 + 0.3).clamp(0.3, 1.0)
  /// - Tüm dünya seçili (195/195) → 1.0x (tam puan)
  /// - Yarı havuz (97/195)        → ~0.65x
  /// - Çok küçük havuz (10/195)   → ~0.34x
  /// - Minimum sınır              → 0.3x
  static double _poolMultiplier() {
    final total = AppState.allCountries.length;
    final pool  = AppState.activePool.length;
    if (total == 0) return 1.0;
    final ratio = pool / total;
    return (ratio * 0.7 + 0.3).clamp(0.3, 1.0);
  }

  static Map<String, int> getInitialScores(GameType type, double multiplier) {
    switch (type) {
      case GameType.distance:
        return {
          'start': (300 * multiplier).round().clamp(60, 300),
          'min':   (100 * multiplier).round().clamp(20, 100),
          'maxPenalty': 20,
        };
      case GameType.borderpath:
        return {
          'start': (100 * multiplier).round().clamp(20, 100),
          'min':   (40  * multiplier).round().clamp(8,  40),
        };
      default: // capital, flag, borderline, findmap
        return {
          'start': (50  * multiplier).round().clamp(10, 50),
          'min':   (20  * multiplier).round().clamp(4,  20),
        };
    }
  }

  // --------------------------------------------------------------------------
  // ROUND MANAGEMENT
  // --------------------------------------------------------------------------

  static Future<void> startNewRound() async {
    debugPrint('🔄 Yeni soru seçiliyor...');

    final available = AppState.activePool;
    if (available.length < 4) {
      debugPrint('⚠️ Yetersiz havuz boyutu: ${available.length}');
      // Fallback: Tüm ülkeleri kullan veya hata fırlat
      return;
    }

    // Hedef ülkeyi rastgele seç
    AppState.targetCountry = available.pickRandom(_random);

    // Çeldiricileri optimize edilmiş algoritma ile seç
    final distractors = _getDistractors(available, AppState.targetCountry);

    // Seçenekleri oluştur ve karıştır
    final options = [AppState.targetCountry, ...distractors]..shuffle(_random);
    _buttons = GameButton.createButtons(options);

    GameLogService.startNewQuestion();
  }

  /// Optimize edilmiş çeldirici algoritması
  static List<Country> _getDistractors(
      List<Country> available, Country target) {
    // 1. Aynı kıtadan adayları filtrele (Stream/Iterables kullanarak memory allocation'ı azalt)
    final sameContinentCandidates = available
        .where((c) =>
            c.iso3 != target.iso3 &&
            c.continents.any((cont) => target.continents.contains(cont)))
        .toList();

    final distractors = <Country>[];

    // Aynı kıtadan rastgele 3 tane al
    if (sameContinentCandidates.isNotEmpty) {
      distractors.addAll(sameContinentCandidates.pickRandomCount(3, _random));
    }

    // Eğer yetmediyse, kalan havuzdan rastgele tamamla
    if (distractors.length < 3) {
      final needed = 3 - distractors.length;
      final otherCandidates = available
          .where((c) =>
              c.iso3 != target.iso3 &&
              !distractors.any((d) => d.iso3 == c.iso3))
          .toList();

      distractors.addAll(otherCandidates.pickRandomCount(needed, _random));
    }

    return distractors;
  }

  // --------------------------------------------------------------------------
  // STANDARD GAME CHECK
  // --------------------------------------------------------------------------

  static Future<bool> checkStandardAnswer(
      String answer, GameType type, int? buttonIndex) async {
    final isCorrect = AppState.targetCountry
        .checkAnswer(answer.trim(), SettingsController.settings.language);

    if (isCorrect) {
      HapticService.correct();
      final countryName = AppState.targetCountry
          .getLocalizedName(SettingsController.settings.language);
      showCorrectSnackBar(countryName);

      final scoreEarned = GameLogService.currentQuestionScore;
      final wrongCount = GameLogService.currentQuestionWrongCount;
      final startTime = GameLogService.currentQuestionStartTime;
      final options = _buttons.map((b) => b.country.iso3).toList();
      final correctAnswer = AppState.targetCountry.iso3;

      GameLogService.submitCorrect();
      await GameLogService.logQuestion(
        gameType: AppState.getGameModeKey(type),
        correctAnswer: correctAnswer,
        options: options,
        wrongCount: wrongCount,
        scoreEarned: scoreEarned,
        questionStartTime: startTime,
      );
      await startNewRound();
      return true;
    } else {
      HapticService.wrong();
      GameLogService.submitWrong();
      _disableButton(buttonIndex);
      return false;
    }
  }

  static void _disableButton(int? buttonIndex) {
    if (buttonIndex != null &&
        buttonIndex >= 0 &&
        buttonIndex < _buttons.length) {
      _buttons[buttonIndex].isActive = false;
    }
  }

  static Future<String> handlePass() async {
    HapticService.pass();
    _distanceGuesses.clear();
    GameLogService.submitPass();
    final passCountryName = AppState.targetCountry
        .getLocalizedName(SettingsController.settings.language);
    await startNewRound();
    return passCountryName;
  }

  // --------------------------------------------------------------------------
  // DISTANCE GAME
  // --------------------------------------------------------------------------

  static Future<GuessResultModel?> processDistanceGuess(
      String inputText) async {
    if (inputText.isEmpty) return null;

    final guessedCountry = _findCountryByName(inputText);
    if (guessedCountry == null) {
      debugPrint('❌ Country didn\'t find: $inputText');
      return null;
    }

    AppState.tempCountry = guessedCountry;
    _distanceGuesses.add(guessedCountry.iso3);

    final target = AppState.targetCountry;

    // Mesafeyi ve yönü hesapla
    final distance = _calculateDistance(
      guessedCountry.latitude,
      guessedCountry.longitude,
      target.latitude,
      target.longitude,
    );

    final directionData = _calculateBearing(
      guessedCountry.latitude,
      guessedCountry.longitude,
      target.latitude,
      target.longitude,
    );

    final isCorrect = guessedCountry.iso3 == target.iso3;

    if (isCorrect) {
      HapticService.correct();
      final countryName =
          target.getLocalizedName(SettingsController.settings.language);
      showCorrectSnackBar(countryName);

      final scoreEarned = GameLogService.currentQuestionScore;
      final wrongCount = GameLogService.currentQuestionWrongCount;
      final startTime = GameLogService.currentQuestionStartTime;
      final correctAnswer = target.iso3;
      final options = List<String>.from(_distanceGuesses);
      _distanceGuesses.clear();

      GameLogService.submitCorrect();
      await GameLogService.logQuestion(
        gameType: 'distance',
        correctAnswer: correctAnswer,
        options: options,
        wrongCount: wrongCount,
        scoreEarned: scoreEarned,
        questionStartTime: startTime,
      );
      await startNewRound();
    } else {
      HapticService.wrong();
      GameLogService.submitWrong();
    }

    return GuessResultModel(
      countryName:
          guessedCountry.getLocalizedName(SettingsController.settings.language),
      distanceKm: distance,
      directionText: directionData.directionText,
      bearing: directionData.bearing,
      isCorrect: isCorrect,
    );
  }

  static Country? _findCountryByName(String name) {
    return AppState.allCountries.firstWhereOrNull(
      (c) => c.checkAnswer(name, SettingsController.settings.language),
    );
  }

  // --------------------------------------------------------------------------
  // BORDER PATH GAME (Optimized)
  // --------------------------------------------------------------------------

  static BorderPathGameData? createBorderPathGame() {
    // Sınır komşusu olan ülkeleri filtrele (sadece bir kez yapılmalı aslında ama şimdilik burada kalsın)
    final connectedCountries =
        AppState.activePool.where((c) => c.borders.isNotEmpty).toList();

    if (connectedCountries.length < 2) return null;

    // Deneme sayısını sınırlayarak sonsuz döngüyü engelle
    for (int i = 0; i < 15; i++) {
      final startCountry = connectedCountries.pickRandom(_random);

      // BFS ile erişilebilir mesafeleri al
      // NOT: _countryMap artık önbellekten geliyor, performans kaybı yok.
      final reachableDistances = _bfsDistances(startCountry);

      // Hedefleri filtrele (Mesafe 2-5 arası)
      final validTargets = connectedCountries.where((c) {
        if (c.iso3 == startCountry.iso3) return false;
        final dist = reachableDistances[c.iso3];
        return dist != null && dist >= 2 && dist <= 5;
      }).toList();

      if (validTargets.isNotEmpty) {
        final targetCountry = validTargets.pickRandom(_random);
        return BorderPathGameData(
          startCountry: startCountry,
          targetCountry: targetCountry,
          optimalPathLength: reachableDistances[targetCountry.iso3]!,
        );
      }
    }
    return null;
  }

  /// BFS Algoritması (Optimize Edilmiş)
  static Map<String, int> _bfsDistances(Country start) {
    final distances = <String, int>{start.iso3: 0};
    final queue = <String>[
      start.iso3
    ]; // Queue'da sadece ISO string tutmak daha hafiftir

    // Cachelenmiş haritayı kullan
    final map = _countryMap;

    var head = 0;
    while (head < queue.length) {
      final currentIso = queue[head++];
      final currentDist = distances[currentIso]!;

      // Haritadan ülkeyi güvenli çek
      final currentCountry = map[currentIso];
      if (currentCountry == null) continue;

      for (var neighborIso in currentCountry.borders) {
        if (!distances.containsKey(neighborIso)) {
          // Komşunun geçerli bir ülke olup olmadığını kontrol et (Veri tutarlılığı için)
          if (map.containsKey(neighborIso)) {
            distances[neighborIso] = currentDist + 1;
            queue.add(neighborIso);
          }
        }
      }
    }
    return distances;
  }

  static Future<void> completeBorderPathGame(
      int moves, int optimalMoves,
      {Country? targetCountry, Country? startCountry}) async {
    final country = targetCountry ?? AppState.targetCountry;
    final countryName =
        country.getLocalizedName(SettingsController.settings.language);
    if (countryName.isNotEmpty) {
      showCorrectSnackBar(countryName);
    }

    final scoreEarned = calculateBorderPathScore(moves, optimalMoves);
    final wrongCount = math.max(0, moves - optimalMoves);
    final startTime = GameLogService.currentQuestionStartTime;
    final correctAnswer = country.iso3;
    final options = startCountry != null
        ? [startCountry.iso3, country.iso3]
        : [country.iso3];

    GameLogService.submitCorrect();
    if (wrongCount > 0) {
      GameLogService.addWrongAnswers(wrongCount);
    }

    await GameLogService.logQuestion(
      gameType: 'borderpath',
      correctAnswer: correctAnswer,
      options: options,
      wrongCount: wrongCount,
      scoreEarned: scoreEarned,
      questionStartTime: startTime,
    );
  }

  /// Doğru cevap verildiğinde alttan yeşil bildirim (SnackBar) gösterir.
  static void showCorrectSnackBar(String countryName) {
    final messenger = AppState.scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    final message = countryName.isNotEmpty
        ? Localization.t('game_common.correct_msg', args: [countryName])
        : Localization.t('game_common.congratulations');

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BORDER PATH HELPERS
  // --------------------------------------------------------------------------

  /// Verilen ülke listesindeki son ülkenin komşularını döner.
  /// [currentPath] mevcut yolda ziyaret edilen ülkeler.
  /// Zaten ziyaret edilenler hariç tutulur ve isme göre sıralanır.
  static List<Country> getAvailableNeighbors(List<Country> currentPath) {
    if (currentPath.isEmpty) return [];

    final Country lastCountry = currentPath.last;
    final List<Country> neighbors = [];

    for (String borderIso3 in lastCountry.borders) {
      final Country? neighbor =
          AppState.allCountries.where((c) => c.iso3 == borderIso3).firstOrNull;

      if (neighbor != null && !currentPath.contains(neighbor)) {
        neighbors.add(neighbor);
      }
    }

    // İsme göre sırala (mevcut dile göre)
    neighbors.sort((a, b) => a
        .getLocalizedName(SettingsController.settings.language)
        .compareTo(b.getLocalizedName(SettingsController.settings.language)));

    return neighbors;
  }

  /// Verilen ülkenin mevcut yoldaki son ülkenin komşusu olup olmadığını kontrol eder.
  static bool isValidNeighborMove(List<Country> currentPath, Country country) {
    if (currentPath.isEmpty) return false;

    final Country lastCountry = currentPath.last;
    return lastCountry.borders.contains(country.iso3) &&
        !currentPath.any((c) => c.iso3 == country.iso3);
  }

  /// Border Path skoru hesaplar.
  ///
  /// Havuz çarpanı uygulanır: küçük havuzda tam skor bile düşük kalır.
  static int calculateBorderPathScore(int moves, int optimalMoves,
      {double? multiplier}) {
    final m = multiplier ?? _poolMultiplier();
    final int wrongCount = (moves - optimalMoves).clamp(0, 1000);
    final rawScore = (100 - wrongCount * 10).clamp(20, 100);
    return (rawScore * m).round().clamp((20 * m).round(), 100);
  }

  /// Border Path performans metnini döner.
  static String getBorderPathPerformanceKey(int score) {
    if (score == 100) return 'game_borderpath.perf_perfect';
    if (score >= 80) return 'game_borderpath.perf_great';
    if (score >= 60) return 'game_borderpath.perf_good';
    return 'game_borderpath.perf_try_harder';
  }

  // --------------------------------------------------------------------------
  // MATH HELPERS
  // --------------------------------------------------------------------------

  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Dünya yarıçapı (km)
    double toRad(double d) => d * math.pi / 180.0;

    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (r * c).roundToDouble(); // Virgülden sonrasını temizle
  }

  static ({String directionText, double bearing}) _calculateBearing(
      double lat1, double lon1, double lat2, double lon2) {
    double toRad(double d) => d * math.pi / 180.0;
    double toDeg(double r) => r * 180.0 / math.pi;

    final phi1 = toRad(lat1);
    final phi2 = toRad(lat2);
    final dLon = toRad(lon2 - lon1);

    final y = math.sin(dLon) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLon);

    final bearing = (toDeg(math.atan2(y, x)) + 360) % 360;

    // Yön metnini belirle (Record pattern)
    const sectors = [
      'north',
      'north_east',
      'east',
      'south_east',
      'south',
      'south_west',
      'west',
      'north_west',
    ];

    // 360 dereceyi 8 dilime böl (her biri 45 derece)
    // +22.5 ofseti kaydırarak dilimleri ortalarız (Örn: North 337.5 - 22.5 arasıdır)
    final index = ((bearing + 22.5) / 45.0).floor() % 8;

    return (
      directionText: Localization.t('directions.${sectors[index]}'),
      bearing: bearing
    );
  }
}

// ============================================================================
// HELPER EXTENSIONS 
// ============================================================================

extension ListRandomExtension<T> on List<T> {
  /// Listeden rastgele bir eleman döner
  T pickRandom(math.Random random) {
    return this[random.nextInt(length)];
  }

  /// Listeden rastgele [count] adet benzersiz eleman seçer
  List<T> pickRandomCount(int count, math.Random random) {
    if (isEmpty) return [];
    if (length <= count) return List.from(this)..shuffle(random);

    final temp = List<T>.from(this)..shuffle(random);
    return temp.take(count).toList();
  }
}
