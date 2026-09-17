import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/screens/settings/settings_controller.dart';

void main() {
  // ===========================================================================
  // HELPER EXTENSIONS TESTLERİ
  // ===========================================================================

  group('ListRandomExtension', () {
    test('pickRandom listeden farklı eleman seçebilmeli', () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final random = math.Random(42); // Sabit seed

      final result = list.pickRandom(random);

      expect(list, contains(result));
    });

    test('pickRandomCount istenen sayıda eleman dönmeli', () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final random = math.Random(42);

      final result = list.pickRandomCount(3, random);

      expect(result.length, 3);
      // Tüm seçilen elemanlar orijinal listede olmalı
      for (var item in result) {
        expect(list, contains(item));
      }
    });

    test('pickRandomCount benzersiz elemanlar dönmeli', () {
      final list = [1, 2, 3, 4, 5];
      final random = math.Random(42);

      final result = list.pickRandomCount(4, random);

      expect(result.toSet().length, result.length); // Benzersiz mi kontrol
    });

    test('pickRandomCount listeden büyük count istenirse tümünü dönmeli', () {
      final list = [1, 2, 3];
      final random = math.Random(42);

      final result = list.pickRandomCount(10, random);

      expect(result.length, 3);
    });

    test('pickRandomCount boş listede boş dönmeli', () {
      final list = <int>[];
      final random = math.Random(42);

      final result = list.pickRandomCount(3, random);

      expect(result, isEmpty);
    });
  });

  // ===========================================================================
  // BORDER PATH SKOR HESAPLAMA
  // ===========================================================================

  group('GameService.calculateBorderPathScore', () {
    test('optimal hamle = oyuncu hamlesi → 100 puan', () {
      expect(GameService.calculateBorderPathScore(3, 3, multiplier: 1.0), 100);
    });

    test('1 fazla hamle → 90 puan', () {
      expect(GameService.calculateBorderPathScore(4, 3, multiplier: 1.0), 90);
    });

    test('2 fazla hamle → 80 puan', () {
      expect(GameService.calculateBorderPathScore(5, 3, multiplier: 1.0), 80);
    });

    test('çok fazla hamle → minimum 20 puan', () {
      expect(GameService.calculateBorderPathScore(20, 3, multiplier: 1.0), 20);
    });

    test('minimum skor 20 altına düşmemeli', () {
      final score = GameService.calculateBorderPathScore(100, 3, multiplier: 1.0);
      expect(score, greaterThanOrEqualTo(20));
    });
  });


  // ===========================================================================
  // BORDER PATH PERFORMANS METNİ
  // ===========================================================================

  group('GameService.getBorderPathPerformanceKey', () {
    test('100 puan → "perf_perfect"', () {
      expect(GameService.getBorderPathPerformanceKey(100),
          'game_borderpath.perf_perfect');
    });

    test('80-99 puan → "perf_great"', () {
      expect(GameService.getBorderPathPerformanceKey(90),
          'game_borderpath.perf_great');
      expect(GameService.getBorderPathPerformanceKey(80),
          'game_borderpath.perf_great');
    });

    test('60-79 puan → "perf_good"', () {
      expect(GameService.getBorderPathPerformanceKey(70),
          'game_borderpath.perf_good');
      expect(GameService.getBorderPathPerformanceKey(60),
          'game_borderpath.perf_good');
    });

    test('60 altı → "perf_try_harder"', () {
      expect(GameService.getBorderPathPerformanceKey(50),
          'game_borderpath.perf_try_harder');
      expect(GameService.getBorderPathPerformanceKey(20),
          'game_borderpath.perf_try_harder');
    });
  });

  // ===========================================================================
  // KOMŞU KONTROL TESTLERİ
  // ===========================================================================

  group('GameService.isValidNeighborMove', () {
    late Country turkey;
    late Country greece;
    late Country germany;

    setUp(() {
      turkey = Country(
        iso3: 'TUR',
        iso2: 'TR',
        englishName: 'Turkey',
        translations: {},
        flagEmoji: '',
        flagUrl: '',
        capital: 'Ankara',
        continents: ['Asia', 'Europe'],
        isUNMember: true,
        latitude: 39,
        longitude: 35,
        borders: ['GRC', 'BGR', 'GEO', 'ARM', 'IRN', 'IRQ', 'SYR', 'AZE'],
        area: 783562,
      );

      greece = Country(
        iso3: 'GRC',
        iso2: 'GR',
        englishName: 'Greece',
        translations: {},
        flagEmoji: '',
        flagUrl: '',
        capital: 'Athens',
        continents: ['Europe'],
        isUNMember: true,
        latitude: 39,
        longitude: 22,
        borders: ['ALB', 'BGR', 'TUR', 'MKD'],
        area: 131990,
      );

      germany = Country(
        iso3: 'DEU',
        iso2: 'DE',
        englishName: 'Germany',
        translations: {},
        flagEmoji: '',
        flagUrl: '',
        capital: 'Berlin',
        continents: ['Europe'],
        isUNMember: true,
        latitude: 51,
        longitude: 9,
        borders: [
          'AUT',
          'BEL',
          'CZE',
          'DNK',
          'FRA',
          'LUX',
          'NLD',
          'POL',
          'CHE'
        ],
        area: 357114,
      );
    });

    test('geçerli komşu hamlesi true dönmeli', () {
      final path = [turkey];
      expect(GameService.isValidNeighborMove(path, greece), true);
    });

    test('komşu olmayan ülke false dönmeli', () {
      final path = [turkey];
      expect(GameService.isValidNeighborMove(path, germany), false);
    });

    test('zaten yolda olan ülke false dönmeli', () {
      final path = [turkey, greece];
      expect(GameService.isValidNeighborMove(path, turkey), false);
    });

    test('boş path false dönmeli', () {
      expect(GameService.isValidNeighborMove([], turkey), false);
    });
  });

  // ===========================================================================
  // FİLTRELENMİŞ ÜLKELER
  // ===========================================================================

  group('AppState.filteredCountries', () {
    setUp(() {
      AppState.allCountries = [
        Country(
          iso3: 'TUR',
          iso2: 'TR',
          englishName: 'Turkey',
          translations: {},
          flagEmoji: '',
          flagUrl: '',
          capital: 'Ankara',
          continents: ['Asia', 'Europe'],
          isUNMember: true,
          latitude: 39,
          longitude: 35,
          borders: [],
          area: 783562,
        ),
        Country(
          iso3: 'DEU',
          iso2: 'DE',
          englishName: 'Germany',
          translations: {},
          flagEmoji: '',
          flagUrl: '',
          capital: 'Berlin',
          continents: ['Europe'],
          isUNMember: true,
          latitude: 51,
          longitude: 9,
          borders: [],
          area: 357114,
        ),
        Country(
          iso3: 'BRA',
          iso2: 'BR',
          englishName: 'Brazil',
          translations: {},
          flagEmoji: '',
          flagUrl: '',
          capital: 'Brasilia',
          continents: ['South America'],
          isUNMember: true,
          latitude: -14,
          longitude: -51,
          borders: [],
          area: 8515767,
        ),
        Country(
          iso3: 'JPN',
          iso2: 'JP',
          englishName: 'Japan',
          translations: {},
          flagEmoji: '',
          flagUrl: '',
          capital: 'Tokyo',
          continents: ['Asia'],
          isUNMember: true,
          latitude: 36,
          longitude: 138,
          borders: [],
          area: 377975,
        ),
        Country(
          iso3: 'TWN',
          iso2: 'TW',
          englishName: 'Taiwan',
          translations: {},
          flagEmoji: '',
          flagUrl: '',
          capital: 'Taipei',
          continents: ['Asia'],
          isUNMember: false,
          latitude: 23,
          longitude: 121,
          borders: [],
          area: 36193,
        ),
      ];
    });

    tearDown(() {
      AppState.allCountries = [];
      SettingsController.gameFilter = GameFilter();
    });

    test('tüm kıtalar açıkken tüm BM üyesi ülkeler dönmeli', () {
      SettingsController.gameFilter =
          GameFilter(); // Varsayılan: hepsi açık, nonUN kapalı

      final result = SettingsController.filteredCountries;
      expect(result.length, 4); // Taiwan hariç (non-UN)
    });

    test('sadece Avrupa filtresi açıkken sadece Avrupa ülkeleri dönmeli', () {
      SettingsController.gameFilter = GameFilter(
        europe: true,
        asia: false,
        africa: false,
        northAmerica: false,
        southAmerica: false,
        oceania: false,
        antarctic: false,
      );

      final result = SettingsController.filteredCountries;
      // Turkey (Asia + Europe) ve Germany (Europe) = 2
      expect(result.length, 2);
      expect(result.any((c) => c.iso3 == 'TUR'), true);
      expect(result.any((c) => c.iso3 == 'DEU'), true);
    });

    test('hiçbir kıta seçili değilken boş liste dönmeli', () {
      SettingsController.gameFilter = GameFilter(
        europe: false,
        asia: false,
        africa: false,
        northAmerica: false,
        southAmerica: false,
        oceania: false,
        antarctic: false,
      );

      expect(SettingsController.filteredCountries, isEmpty);
    });

    test('includeNonUN açıkken BM üyesi olmayan ülkeler de gelmeli', () {
      SettingsController.gameFilter = GameFilter(includeNonUN: true);

      final result = SettingsController.filteredCountries;
      expect(result.length, 5); // Taiwan dahil
      expect(result.any((c) => c.iso3 == 'TWN'), true);
    });

    test('sadece Antarktika ve nonUN açıkken Antarktika ülkeleri dönmeli', () {
      AppState.allCountries.add(Country(
        iso3: 'ATA',
        iso2: 'AQ',
        englishName: 'Antarctica',
        translations: {},
        flagEmoji: '',
        flagUrl: '',
        capital: '',
        continents: ['Antarctica'],
        isUNMember: false,
        latitude: -90,
        longitude: 0,
        borders: [],
        area: 14000000,
      ));

      SettingsController.gameFilter = GameFilter(
        europe: false,
        asia: false,
        africa: false,
        northAmerica: false,
        southAmerica: false,
        oceania: false,
        antarctic: true,
        includeNonUN: true,
      );

      final result = SettingsController.filteredCountries;
      expect(result.length, 1);
      expect(result.first.iso3, 'ATA');
    });
  });

  // ===========================================================================
  // BORDER PATH SKOR — EDGE CASE'LER
  // ===========================================================================

  group('GameService.calculateBorderPathScore (edge cases)', () {
    test('moves < optimal → yine 100 dönmeli (negatif penalty yok)', () {
      expect(
          GameService.calculateBorderPathScore(2, 5, multiplier: 1.0), 100);
    });

    test('moves == 0, optimal == 0 → 100 dönmeli', () {
      expect(
          GameService.calculateBorderPathScore(0, 0, multiplier: 1.0), 100);
    });

    test('1 hamle farkla skor tam 90 olmalı', () {
      expect(
          GameService.calculateBorderPathScore(4, 3, multiplier: 1.0), 90);
    });

    test('8 fazla hamle → minimum 20 puan', () {
      final score =
          GameService.calculateBorderPathScore(11, 3, multiplier: 1.0);
      expect(score, equals(20));
    });
  });




  // ===========================================================================
  // PERFORMANS METNİ — SINIR DEĞERLER
  // ===========================================================================

  group('GameService.getBorderPathPerformanceKey (sınır değerler)', () {
    test('0 puan → "perf_try_harder"', () {
      expect(GameService.getBorderPathPerformanceKey(0),
          'game_borderpath.perf_try_harder');
    });

    test('59 puan → "perf_try_harder"', () {
      expect(GameService.getBorderPathPerformanceKey(59),
          'game_borderpath.perf_try_harder');
    });

    test('60 puan → "perf_good" (sınır)', () {
      expect(GameService.getBorderPathPerformanceKey(60),
          'game_borderpath.perf_good');
    });

    test('79 puan → "perf_good"', () {
      expect(GameService.getBorderPathPerformanceKey(79),
          'game_borderpath.perf_good');
    });

    test('80 puan → "perf_great" (sınır)', () {
      expect(GameService.getBorderPathPerformanceKey(80),
          'game_borderpath.perf_great');
    });

    test('99 puan → "perf_great"', () {
      expect(GameService.getBorderPathPerformanceKey(99),
          'game_borderpath.perf_great');
    });
  });

  // ===========================================================================
  // LIST RANDOM — EDGE CASE'LER
  // ===========================================================================

  group('ListRandomExtension (edge cases)', () {
    test('tek elemanlı listede pickRandom o elemanı dönmeli', () {
      final list = [42];
      final random = math.Random(42);
      expect(list.pickRandom(random), 42);
    });

    test('pickRandomCount count=0 boş liste dönmeli', () {
      final list = [1, 2, 3];
      final random = math.Random(42);
      expect(list.pickRandomCount(0, random), isEmpty);
    });

    test('pickRandomCount count=1 tek elemanlı liste dönmeli', () {
      final list = [1, 2, 3, 4, 5];
      final random = math.Random(42);
      final result = list.pickRandomCount(1, random);
      expect(result.length, 1);
      expect(list, contains(result.first));
    });
  });

  // ===========================================================================
  // GET INITIAL SCORES (BAŞLANGIÇ PUANLARI & CEZA TAVANI)
  // ===========================================================================

  group('GameService.getInitialScores', () {
    test('distance oyunu 1.0 çarpanında start=300, min=100, maxPenalty=20 dönmeli', () {
      final scores = GameService.getInitialScores(GameType.distance, 1.0);

      expect(scores['start'], 300);
      expect(scores['min'], 100);
      expect(scores['maxPenalty'], 20);
    });

    test('distance oyunu 0.5 çarpanında start=150, min=50, maxPenalty=20 dönmeli', () {
      final scores = GameService.getInitialScores(GameType.distance, 0.5);

      expect(scores['start'], 150);
      expect(scores['min'], 50);
      expect(scores['maxPenalty'], 20);
    });

    test('standart oyunlar (capital, flag, coatofarms vs.) maxPenalty içermemeli', () {
      final capitalScores = GameService.getInitialScores(GameType.capital, 1.0);
      expect(capitalScores['start'], 50);
      expect(capitalScores['min'], 20);
      expect(capitalScores.containsKey('maxPenalty'), false);

      final flagScores = GameService.getInitialScores(GameType.flag, 1.0);
      expect(flagScores['start'], 50);
      expect(flagScores['min'], 20);
      expect(flagScores.containsKey('maxPenalty'), false);

      final coatScores = GameService.getInitialScores(GameType.coatofarms, 1.0);
      expect(coatScores['start'], 50);
      expect(coatScores['min'], 20);
      expect(coatScores.containsKey('maxPenalty'), false);
    });

    test('borderpath oyunu 1.0 çarpanında start=100, min=40 dönmeli', () {
      final scores = GameService.getInitialScores(GameType.borderpath, 1.0);
      expect(scores['start'], 100);
      expect(scores['min'], 40);
      expect(scores.containsKey('maxPenalty'), false);
    });
  });
}


