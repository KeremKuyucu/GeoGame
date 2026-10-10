import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geogame/services/bonus_service.dart';
import 'package:geogame/services/game_log_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    BonusService.resetForTesting();
  });

  tearDown(() {
    BonusService.resetForTesting();
  });

  group('BonusService Tests', () {
    test('Başlangıçta bonus pasif olmalı ve çarpan 1 olmalı', () {
      expect(BonusService.isActive, isFalse);
      expect(BonusService.scoreMultiplier, equals(1));
      expect(BonusService.remainingTime, equals(Duration.zero));
    });

    test('activate() çağrıldığında bonus aktif olmalı ve 5 dakika eklenmeli', () {
      BonusService.activate();

      expect(BonusService.isActive, isTrue);
      expect(BonusService.scoreMultiplier, equals(2));
      expect(BonusService.remainingTime.inMinutes, inInclusiveRange(4, 5));
    });

    test('activate() üst üste çağrıldığında süre stacklenmeli (+5 dk)', () {
      BonusService.activate();
      final firstRemaining = BonusService.remainingTime;

      BonusService.activate();
      final stackedRemaining = BonusService.remainingTime;

      // İkinci aktivasyondan sonra süre yaklaşık 10 dakika olmalı
      expect(stackedRemaining.inMinutes, inInclusiveRange(8, 10));
      expect(stackedRemaining > firstRemaining, isTrue);
    });

    test('Süre dolduğunda bonus otomatik pasife dönmeli', () {
      // 1 dakika önce bitmiş bir süre ata
      final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
      BonusService.resetForTesting(customEndTime: pastTime);

      expect(BonusService.isActive, isFalse);
      expect(BonusService.scoreMultiplier, equals(1));
      expect(BonusService.remainingTime, equals(Duration.zero));
    });

    test('formattedRemainingTime doğru formatta dönmeli', () {
      // 4 dakika 30 saniye kalmış gibi test
      final futureTime = DateTime.now().add(const Duration(minutes: 4, seconds: 30));
      BonusService.resetForTesting(customEndTime: futureTime);

      final formatted = BonusService.formattedRemainingTime;
      expect(formatted, matches(r'^\d{2}:\d{2}$'));
      expect(formatted.startsWith('04:'), isTrue);
    });

    test('Pasifken formattedRemainingTime 00:00 dönmeli', () {
      expect(BonusService.formattedRemainingTime, equals('00:00'));
    });

    test('Toplam bonus süresi 30 dakikalık tavan sınırı aşmamalı', () {
      // 10 kez üst üste çağırarak 50 dk eklemeyi dene
      for (int i = 0; i < 10; i++) {
        BonusService.activate();
      }

      expect(BonusService.isActive, isTrue);
      // Süre en fazla 30 dakika olmalı
      expect(BonusService.remainingTime.inMinutes, lessThanOrEqualTo(30));
    });

    test('clearBonus() bonusu tamamen sıfırlamalı', () async {
      BonusService.activate();
      expect(BonusService.isActive, isTrue);

      await BonusService.clearBonus();

      expect(BonusService.isActive, isFalse);
      expect(BonusService.remainingTime, equals(Duration.zero));
    });

    test('loadBonus() manipüle edilmiş aşırı uzun süreyi tavan sınıra çekmeli', () async {
      final prefs = await SharedPreferences.getInstance();
      // 1 yıl sonrasına ayarlanmış manipüle edilmiş tarih simülasyonu
      final futureTime = DateTime.now().add(const Duration(days: 365));
      await prefs.setString('geogame_bonus_end_time', futureTime.toIso8601String());

      await BonusService.loadBonus();

      expect(BonusService.isActive, isTrue);
      expect(BonusService.remainingTime.inMinutes, lessThanOrEqualTo(30));
    });
  });

  group('GameSession & Bonus Entegrasyon Testleri', () {
    test('Bonus pasifken submitCorrect normal puan vermeli', () {
      GameLogService.resetSession(startScore: 100, minScore: 20);

      GameLogService.submitCorrect();

      expect(GameLogService.lastQuestionScoreEarned, equals(100));
      expect(GameLogService.totalScore, equals(100));
    });

    test('Bonus aktifken submitCorrect 2x puan vermeli', () {
      BonusService.activate();
      GameLogService.resetSession(startScore: 100, minScore: 20);

      GameLogService.submitCorrect();

      expect(GameLogService.lastQuestionScoreEarned, equals(200));
      expect(GameLogService.totalScore, equals(200));
    });

    test('Bonus bittiğinde puanlama tekrar 1x olmalı', () {
      BonusService.activate();
      GameLogService.resetSession(startScore: 100, minScore: 20);

      // İlk soru bonuslu
      GameLogService.submitCorrect();
      expect(GameLogService.totalScore, equals(200));

      // Bonus süresi bitti
      BonusService.resetForTesting(
        customEndTime: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      // İkinci soru normal
      GameLogService.submitCorrect();
      expect(GameLogService.lastQuestionScoreEarned, equals(100));
      expect(GameLogService.totalScore, equals(300));
    });
  });
}
