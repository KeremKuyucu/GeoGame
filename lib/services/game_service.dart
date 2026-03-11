import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game/guess_result.dart';
import 'package:geogame/models/game/border_path_data.dart';
import 'package:geogame/models/game_metadata.dart';

import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/localization_service.dart';

// ============================================================================
// GAME SERVICE
// ============================================================================

class GameService {
  static final math.Random _random = math.Random();

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
    final scores = _getInitialScores(type);
    AppState.session.reset(
      startScore: scores['start']!,
      minScore: scores['min']!,
    );

    // Cache'i temizle veya güncelle (Eğer ülke listesi değişmişse diye)
    _cachedCountryMap = null;

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
    AppState.buttons = GameButton.createButtons(options);
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
        .checkAnswer(answer.trim(), AppState.settings.language);

    if (isCorrect) {
      AppState.session.submitCorrect();
      // await ekleyerek log işleminin bitmesini garantiye alıyoruz
      await GameLogService.saveProgress(AppState.getGameModeKey(type));
      await startNewRound();
      return true;
    } else {
      AppState.session.submitWrong();
      _disableButton(buttonIndex);
      return false;
    }
  }

  static void _disableButton(int? buttonIndex) {
    if (buttonIndex != null &&
        buttonIndex >= 0 &&
        buttonIndex < AppState.buttons.length) {
      AppState.buttons[buttonIndex].isActive = false;
    }
  }

  static Future<String> handlePass() async {
    AppState.session.submitPass();
    final passCountryName =
        AppState.targetCountry.getLocalizedName(AppState.settings.language);
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
      AppState.session.submitCorrect();
      await startNewRound();
      await GameLogService.saveProgress('distance');
    } else {
      AppState.session.submitWrong();
    }

    return GuessResultModel(
      countryName: guessedCountry.getLocalizedName(AppState.settings.language),
      distanceKm: distance,
      directionText: directionData.directionText,
      bearing: directionData.bearing,
      isCorrect: isCorrect,
    );
  }

  static Country? _findCountryByName(String name) {
    return AppState.allCountries.firstWhereOrNull(
      (c) => c.checkAnswer(name, AppState.settings.language),
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
      int moves, int optimalMoves) async {
    AppState.session.submitCorrect();

    final penalty = math.max(0, moves - optimalMoves);
    if (penalty > 0) {
      AppState.session.wrongCount += penalty;
    }

    await GameLogService.saveProgress('borderpath');
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
        .getLocalizedName(AppState.settings.language)
        .compareTo(b.getLocalizedName(AppState.settings.language)));

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
  static int calculateBorderPathScore(int moves, int optimalMoves) {
    final int wrongCount = (moves - optimalMoves).clamp(0, 1000);
    return (100 - wrongCount * 10).clamp(20, 100);
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
// HELPER EXTENSIONS (CLEAN CODE)
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

// ============================================================================
// MODELS (Moved to bottom for single-file structure)
// ============================================================================
