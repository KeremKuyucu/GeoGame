import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/localization_service.dart';

// ============================================================================
// ENUMS & MODELS
// ============================================================================


class GuessResultModel {
  final String countryName;
  final double distanceKm;
  final String directionText;
  final double bearing;
  final bool isCorrect;

  GuessResultModel({
    required this.countryName,
    required this.distanceKm,
    required this.directionText,
    required this.bearing,
    required this.isCorrect,
  });
}

class BorderPathGameData {
  final Country startCountry;
  final Country targetCountry;
  final int optimalPathLength;

  BorderPathGameData({
    required this.startCountry,
    required this.targetCountry,
    required this.optimalPathLength,
  });
}

// ============================================================================
// GAME SERVICE
// ============================================================================

class GameService {
  static final math.Random _random = math.Random();

  // --------------------------------------------------------------------------
  // GAME INITIALIZATION
  // --------------------------------------------------------------------------

  /// Oyunu başlatır ve ilk soruyu hazırlar
  static Future<void> initializeGame(GameType type) async {
    final scores = _getInitialScores(type);
    AppState.session.reset(
      startScore: scores['start']!,
      minScore: scores['min']!,
    );

    if (type != GameType.borderpath) {
      await startNewRound();
    }
  }

  static Map<String, int> _getInitialScores(GameType type) {
    switch (type) {
      case GameType.distance:
        return {'start': 300, 'min': 100};
      case GameType.borderpath:
        return {'start': 100, 'min': 40};
      default:
        return {'start': 50, 'min': 20};
    }
  }


  // --------------------------------------------------------------------------
  // ROUND MANAGEMENT
  // --------------------------------------------------------------------------

  /// Yeni soru seçer ve butonları hazırlar
  static Future<void> startNewRound() async {
    debugPrint("🔄 Yeni soru seçiliyor...");

    final available = AppState.activePool;
    if (available.length < 4) {
      debugPrint("⚠️ Yeterli ülke yok!");
      return;
    }

    // Hedef ülkeyi seç
    AppState.targetCountry = available[_random.nextInt(available.length)];

    // Çeldiricileri hazırla
    final distractors = _getDistractors(available);

    // Tüm seçenekleri karıştır ve butonları oluştur
    final options = [AppState.targetCountry, ...distractors]..shuffle();
    AppState.buttons = GameButton.createButtons(options);

    debugPrint("🎯 Hedef: ${AppState.targetCountry.englishName}");
  }

  static List<Country> _getDistractors(List<Country> available) {
    // Aynı kıtadan adayları bul
    final sameContinentOptions = available.where((c) {
      return c.englishName != AppState.targetCountry.englishName &&
          c.continents.any((cont) =>
              AppState.targetCountry.continents.contains(cont));
    }).toList()..shuffle();

    final distractors = <Country>[];
    distractors.addAll(sameContinentOptions.take(3));

    // Yeterli değilse, rastgele tamamla
    if (distractors.length < 3) {
      final otherOptions = available.where((c) {
        return c.englishName != AppState.targetCountry.englishName &&
            !distractors.any((d) => d.englishName == c.englishName);
      }).toList()..shuffle();

      distractors.addAll(otherOptions.take(3 - distractors.length));
    }

    return distractors;
  }

  /// Pas geçme işlemi
  static Future<String> handlePass() async {
    AppState.session.submitPass();
    final passCountryName = AppState.targetCountry
        .getLocalizedName(AppState.settings.language);
    await startNewRound();
    return passCountryName;
  }

  // --------------------------------------------------------------------------
  // STANDARD GAME ANSWER CHECK
  // --------------------------------------------------------------------------

  /// Standart oyunlar için cevap kontrolü (Bayrak, Başkent, Sınır)
  static Future<bool> checkStandardAnswer(String answer, GameType type, int? buttonIndex,) async {
    final isCorrect = AppState.targetCountry
        .checkAnswer(answer.trim(), AppState.settings.language);

    if (isCorrect) {
      AppState.session.submitCorrect();
      GameLogService.saveProgress(AppState.getGameModeKey(type));
      await startNewRound();
      return true;
    }

    AppState.session.submitWrong();
    _disableButton(buttonIndex);
    return false;
  }

  static void _disableButton(int? buttonIndex) {
    if (buttonIndex != null &&
        buttonIndex >= 0 &&
        buttonIndex < AppState.buttons.length) {
      AppState.buttons[buttonIndex].isActive = false;
    }
  }

  // --------------------------------------------------------------------------
  // DISTANCE GAME
  // --------------------------------------------------------------------------

  /// Mesafe oyunu için tahmin işleme
  static Future<GuessResultModel?> processDistanceGuess(String inputText) async {
    if (inputText.isEmpty) return null;

    final guessedCountry = _findCountryByName(inputText);
    if (guessedCountry == null) {
      debugPrint("Ülke bulunamadı: $inputText");
      return null;
    }

    AppState.tempCountry = guessedCountry;

    final distance = _calculateDistance(
      guessedCountry.latitude,
      guessedCountry.longitude,
      AppState.targetCountry.latitude,
      AppState.targetCountry.longitude,
    );

    final directionData = _calculateBearing(
      guessedCountry.latitude,
      guessedCountry.longitude,
      AppState.targetCountry.latitude,
      AppState.targetCountry.longitude,
    );

    final isCorrect =
        guessedCountry.englishName == AppState.targetCountry.englishName;

    if (isCorrect) {
      AppState.session.submitCorrect();
      GameLogService.saveProgress("distance");
    } else {
      AppState.session.submitWrong();
    }

    return GuessResultModel(
      countryName: guessedCountry.getLocalizedName(AppState.settings.language),
      distanceKm: distance,
      directionText: directionData['text'] as String,
      bearing: directionData['bearing'] as double,
      isCorrect: isCorrect,
    );
  }

  static Country? _findCountryByName(String name) {
    try {
      return AppState.allCountries.firstWhere(
            (c) => c.checkAnswer(name, AppState.settings.language),
      );
    } catch (e) {
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // BORDER PATH GAME
  // --------------------------------------------------------------------------

  static BorderPathGameData? createBorderPathGame() {
    final filteredCountries = AppState.activePool
        .where((c) => c.borders.isNotEmpty)
        .toList();

    if (filteredCountries.length < 2) return null;

    final startCountry =
    filteredCountries[_random.nextInt(filteredCountries.length)];

    final validTargets = _findValidTargets(startCountry, filteredCountries);
    if (validTargets.isEmpty) return null;

    final targetCountry =
    validTargets[_random.nextInt(validTargets.length)];
    final optimalPath = calculateMinDistance(startCountry, targetCountry);

    return BorderPathGameData(
      startCountry: startCountry,
      targetCountry: targetCountry,
      optimalPathLength: optimalPath,
    );
  }

  static List<Country> _findValidTargets(Country start, List<Country> candidates,) {
    final validTargets = <Country>[];

    for (var country in candidates) {
      if (country.iso3 == start.iso3) continue;

      final distance = calculateMinDistance(start, country);
      if (distance >= 2 && distance <= 5) {
        validTargets.add(country);
      }
    }

    // Fallback: Herhangi bir farklı ülke
    if (validTargets.isEmpty) {
      return candidates.where((c) => c.iso3 != start.iso3).toList();
    }

    return validTargets;
  }

  /// BFS ile iki ülke arasındaki minimum mesafe
  static int calculateMinDistance(Country start, Country target) {
    if (start.iso3 == target.iso3) return 0;

    final distances = <String, int>{start.iso3: 0};
    final queue = <Country>[start];
    var head = 0;

    while (head < queue.length) {
      final current = queue[head++];
      final currentDistance = distances[current.iso3]!;

      for (var neighborIso3 in current.borders) {
        if (distances.containsKey(neighborIso3)) continue;

        final neighbor = AppState.allCountries
            .where((c) => c.iso3 == neighborIso3)
            .firstOrNull;

        if (neighbor == null) continue;

        distances[neighborIso3] = currentDistance + 1;

        if (neighborIso3 == target.iso3) {
          return currentDistance + 1;
        }

        queue.add(neighbor);
      }
    }

    return 999; // Ulaşılamaz
  }

  /// Border Path oyunu tamamlandığında puan kaydet
  static Future<void> completeBorderPathGame(int moves, int optimalMoves,) async {
    AppState.session.submitCorrect();

    final wrongCount = math.max(0, moves - optimalMoves);
    for (var i = 0; i < wrongCount; i++) {
      AppState.session.submitWrong();
    }

    GameLogService.saveProgress("borderpath");

    debugPrint("🏆 Border Path tamamlandı!");
    debugPrint("📊 Hamle: $moves, Optimal: $optimalMoves");
  }

  // --------------------------------------------------------------------------
  // MATHEMATICAL HELPERS
  // --------------------------------------------------------------------------

  /// Haversine formülü ile mesafe hesaplama
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2,) {
    const earthRadius = 6371.0; // km
    double toRad(double degree) => degree * math.pi / 180.0;

    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (earthRadius * c).roundToDouble();
  }

  /// Yön (bearing) hesaplama
  static Map<String, dynamic> _calculateBearing(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    double toRad(double deg) => deg * math.pi / 180.0;
    double toDeg(double rad) => rad * 180.0 / math.pi;

    final phi1 = toRad(lat1);
    final phi2 = toRad(lat2);
    final dLon = toRad(lon2 - lon1);

    final y = math.sin(dLon) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLon);

    var bearing = toDeg(math.atan2(y, x));
    bearing = (bearing + 360) % 360;

    const directionKeys = [
      "north", "north_east", "east", "south_east",
      "south", "south_west", "west", "north_west"
    ];

    final index = ((bearing + 22.5) / 45.0).floor() % 8;
    final directionText = Localization.t("directions.${directionKeys[index]}");

    return {
      'text': directionText,
      'bearing': bearing,
    };
  }
}