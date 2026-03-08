import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/game_service.dart';

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
      expect(GameService.calculateBorderPathScore(3, 3), 100);
    });

    test('1 fazla hamle → 90 puan', () {
      expect(GameService.calculateBorderPathScore(4, 3), 90);
    });

    test('2 fazla hamle → 80 puan', () {
      expect(GameService.calculateBorderPathScore(5, 3), 80);
    });

    test('çok fazla hamle → minimum 20 puan', () {
      expect(GameService.calculateBorderPathScore(20, 3), 20);
    });

    test('minimum skor 20 altına düşmemeli', () {
      final score = GameService.calculateBorderPathScore(100, 3);
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
      AppState.filter = GameFilter();
    });

    test('tüm kıtalar açıkken tüm BM üyesi ülkeler dönmeli', () {
      AppState.filter = GameFilter(); // Varsayılan: hepsi açık, nonUN kapalı

      final result = AppState.filteredCountries;
      expect(result.length, 4); // Taiwan hariç (non-UN)
    });

    test('sadece Avrupa filtresi açıkken sadece Avrupa ülkeleri dönmeli', () {
      AppState.filter = GameFilter(
        europe: true,
        asia: false,
        africa: false,
        northAmerica: false,
        southAmerica: false,
        oceania: false,
        antarctic: false,
      );

      final result = AppState.filteredCountries;
      // Turkey (Asia + Europe) ve Germany (Europe) = 2
      expect(result.length, 2);
      expect(result.any((c) => c.iso3 == 'TUR'), true);
      expect(result.any((c) => c.iso3 == 'DEU'), true);
    });

    test('hiçbir kıta seçili değilken boş liste dönmeli', () {
      AppState.filter = GameFilter(
        europe: false,
        asia: false,
        africa: false,
        northAmerica: false,
        southAmerica: false,
        oceania: false,
        antarctic: false,
      );

      expect(AppState.filteredCountries, isEmpty);
    });

    test('includeNonUN açıkken BM üyesi olmayan ülkeler de gelmeli', () {
      AppState.filter = GameFilter(includeNonUN: true);

      final result = AppState.filteredCountries;
      expect(result.length, 5); // Taiwan dahil
      expect(result.any((c) => c.iso3 == 'TWN'), true);
    });
  });
}
