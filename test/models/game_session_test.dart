import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';

void main() {
  group('GameSession', () {
    late GameSession session;

    setUp(() {
      session = GameSession();
      session.reset(startScore: 50, minScore: 20);
    });

    // =========================================================================
    // RESET
    // =========================================================================

    test('reset tüm değerleri sıfırlamalı', () {
      session.submitCorrect();
      session.submitWrong();
      session.reset(startScore: 100, minScore: 30);

      expect(session.totalScore, 0);
      expect(session.correctCount, 0);
      expect(session.wrongCount, 0);
      expect(session.passCount, 0);
      expect(session.currentQuestionScore, 100);
      expect(session.sessionId, isNotEmpty);
    });

    test('reset her seferinde yeni sessionId üretmeli', () {
      final firstId = session.sessionId;
      session.reset(startScore: 50, minScore: 20);
      final secondId = session.sessionId;

      expect(firstId, isNot(equals(secondId)));
    });

    // =========================================================================
    // DOĞRU CEVAP
    // =========================================================================

    test('submitCorrect skoru artırmalı', () {
      session.submitCorrect();

      expect(session.correctCount, 1);
      expect(session.totalScore, 50);
    });

    test('submitCorrect ardışık çağrılarında skor doğru toplanmalı', () {
      session.submitCorrect();
      session.submitCorrect();
      session.submitCorrect();

      expect(session.correctCount, 3);
      expect(session.totalScore, 150); // 50 + 50 + 50
    });

    test('submitCorrect sonrası soru puanı sıfırlanmalı (startScore)', () {
      session.submitWrong(); // 50 -> 40
      session.submitCorrect(); // 40 puan kazanılır, sıfırlanır

      expect(session.totalScore, 40);
      expect(session.currentQuestionScore, 50); // Sıfırlandı
    });

    // =========================================================================
    // YANLIŞ CEVAP
    // =========================================================================

    test('submitWrong soru puanını 10 düşürmeli', () {
      session.submitWrong();

      expect(session.wrongCount, 1);
      expect(session.currentQuestionScore, 40); // 50 - 10
    });

    test('submitWrong minimum puanın altına düşmemeli', () {
      // 50 -> 40 -> 30 -> 20 -> 20 -> 20
      session.submitWrong();
      session.submitWrong();
      session.submitWrong();
      session.submitWrong(); // Zaten 20, daha fazla düşmemeli
      session.submitWrong();

      expect(session.currentQuestionScore, 20); // minScore
      expect(session.wrongCount, 5);
    });

    test('submitWrong toplam skoru etkilememeli', () {
      session.submitWrong();
      session.submitWrong();

      expect(session.totalScore, 0); // Skor değişmemeli
    });

    // =========================================================================
    // PAS
    // =========================================================================

    test('submitPass sayacı artırmalı ve soruyu sıfırlamalı', () {
      session.submitWrong(); // 50 -> 40
      session.submitPass();

      expect(session.passCount, 1);
      expect(session.currentQuestionScore, 50); // Sıfırlandı
      expect(session.totalScore, 0); // Skor artmaz
    });

    // =========================================================================
    // KARMA SENARYO
    // =========================================================================

    test('karma senaryo: doğru + yanlış + pas', () {
      // Soru 1: 2 yanlış + doğru
      session.submitWrong(); // 50 -> 40
      session.submitWrong(); // 40 -> 30
      session.submitCorrect(); // +30 puan

      // Soru 2: pas
      session.submitPass();

      // Soru 3: direkt doğru
      session.submitCorrect(); // +50 puan

      expect(session.totalScore, 80); // 30 + 50
      expect(session.correctCount, 2);
      expect(session.wrongCount, 2);
      expect(session.passCount, 1);
    });

    // =========================================================================
    // DISTANCE GAME SKORU
    // =========================================================================

    test('distance oyunu başlangıç skoru 300 olmalı', () {
      session.reset(startScore: 300, minScore: 100);

      expect(session.currentQuestionScore, 300);

      session.submitWrong(); // 300 -> 290
      expect(session.currentQuestionScore, 290);
    });

    test('distance oyunu minimum skoru 100 olmalı', () {
      session.reset(startScore: 300, minScore: 100);

      for (int i = 0; i < 25; i++) {
        session.submitWrong();
      }

      expect(session.currentQuestionScore, 100); // Minimum
    });
  });

  // ===========================================================================
  // GAME FILTER
  // ===========================================================================

  group('GameFilter', () {
    test('varsayılan değerler doğru olmalı', () {
      final filter = GameFilter();

      expect(filter.europe, true);
      expect(filter.asia, true);
      expect(filter.africa, true);
      expect(filter.northAmerica, true);
      expect(filter.southAmerica, true);
      expect(filter.oceania, true);
      expect(filter.antarctic, true);
      expect(filter.isButtonMode, true);
      expect(filter.includeNonUN, false);
    });

    test('fromMap doğru doldurulmalı', () {
      final filter = GameFilter.fromMap({
        'europe': false,
        'asia': true,
        'africa': false,
        'includeNonUN': true,
      });

      expect(filter.europe, false);
      expect(filter.asia, true);
      expect(filter.africa, false);
      expect(filter.includeNonUN, true);
      // Belirtilmeyenler varsayılan olmalı
      expect(filter.northAmerica, true);
    });

    test('toMap tüm alanları içermeli', () {
      final filter = GameFilter();
      final map = filter.toMap();

      expect(map.containsKey('europe'), true);
      expect(map.containsKey('asia'), true);
      expect(map.containsKey('africa'), true);
      expect(map.containsKey('northAmerica'), true);
      expect(map.containsKey('southAmerica'), true);
      expect(map.containsKey('oceania'), true);
      expect(map.containsKey('antarctic'), true);
      expect(map.containsKey('isButtonMode'), true);
      expect(map.containsKey('includeNonUN'), true);
    });

    test('fromMap → toMap dönüşümü tutarlı olmalı', () {
      final original = GameFilter(
        europe: false,
        asia: true,
        africa: false,
        northAmerica: true,
        southAmerica: false,
        oceania: true,
        antarctic: false,
        isButtonMode: false,
        includeNonUN: true,
      );

      final restored = GameFilter.fromMap(original.toMap());

      expect(restored.europe, original.europe);
      expect(restored.asia, original.asia);
      expect(restored.africa, original.africa);
      expect(restored.includeNonUN, original.includeNonUN);
      expect(restored.isButtonMode, original.isButtonMode);
    });
  });

  // ===========================================================================
  // APP SETTINGS
  // ===========================================================================

  group('AppSettings', () {
    test('varsayılan değerler doğru olmalı', () {
      final settings = AppSettings();

      expect(settings.darkTheme, true);
      expect(settings.language, 'eng');
    });

    test('fromMap doğru doldurulmalı', () {
      final settings = AppSettings.fromMap({
        'darkTheme': false,
        'language': 'tur',
      });

      expect(settings.darkTheme, false);
      expect(settings.language, 'tur');
    });

    test('fromMap boş/null language varsayılan olmalı', () {
      final settings1 = AppSettings.fromMap({'language': ''});
      final settings2 = AppSettings.fromMap({'language': null});
      final settings3 = AppSettings.fromMap({});

      expect(settings1.language, 'eng');
      expect(settings2.language, 'eng');
      expect(settings3.language, 'eng');
    });
  });

  // ===========================================================================
  // USER PROFILE
  // ===========================================================================

  group('UserProfile', () {
    test('fromMap doğru doldurulmalı', () {
      final profile = UserProfile.fromMap({
        'name': 'Kerem',
        'avatarUrl': 'https://example.com/avatar.png',
      });

      expect(profile.name, 'Kerem');
      expect(profile.avatarUrl, 'https://example.com/avatar.png');
    });

    test('toMap tüm alanları içermeli', () {
      final profile = UserProfile(
        name: 'Test',
        avatarUrl: 'https://example.com/test.png',
      );
      final map = profile.toMap();

      expect(map['name'], 'Test');
      expect(map['avatarUrl'], 'https://example.com/test.png');
    });
  });

  // ===========================================================================
  // GAME BUTTON
  // ===========================================================================

  group('GameButton', () {
    test('createButtons doğru sayıda buton üretmeli', () {
      final countries = List.generate(
        4,
        (i) => Country(
          iso3: 'C$i',
          iso2: 'C$i',
          englishName: 'Country$i',
          translations: {},
          flagEmoji: '',
          flagUrl: '',
          capital: '',
          continents: [],
          isUNMember: true,
          latitude: 0,
          longitude: 0,
          borders: [],
          area: 0,
        ),
      );

      final buttons = GameButton.createButtons(countries);

      expect(buttons.length, 4);
      expect(buttons.every((b) => b.isActive), true);
    });
  });
}
