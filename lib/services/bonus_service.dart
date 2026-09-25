import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2x Puan Bonusu Servisi.
/// Ödüllü reklam izlendiğinde 5 dakikalığına tüm puanları 2x yapar.
/// Birden fazla reklam izlenirse süre stacklenir (+5 dk).
/// Oyundan çıkılsa bile süre DateTime bazlı olarak saymaya devam eder.
class BonusService {
  BonusService._();

  static const String _storageKey = 'geogame_bonus_end_time';
  static DateTime? _bonusEndTime;

  /// Bonus süresi değiştiğinde dinleyicileri tetiklemek için notifier.
  static final ValueNotifier<DateTime?> bonusEndTimeNotifier =
      ValueNotifier<DateTime?>(null);

  /// Bonusun şu anda aktif olup olmadığını döner.
  static bool get isActive =>
      _bonusEndTime != null && DateTime.now().isBefore(_bonusEndTime!);

  /// Kalan bonus süresi. Aktif değilse Duration.zero döner.
  static Duration get remainingTime => isActive
      ? _bonusEndTime!.difference(DateTime.now())
      : Duration.zero;

  /// Puan çarpanı: Aktifse 2, değilse 1.
  static int get scoreMultiplier => isActive ? 2 : 1;

  /// Kalan sürenin formatlanmış metni (örnek: "04:35", "12:10").
  static String get formattedRemainingTime {
    final remaining = remainingTime;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 5 dakikalık 2x bonus ekler.
  /// Zaten aktifse mevcut sürenin üzerine 5 dakika ekler (stacking).
  static void activate() {
    if (isActive) {
      _bonusEndTime = _bonusEndTime!.add(const Duration(minutes: 5));
    } else {
      _bonusEndTime = DateTime.now().add(const Duration(minutes: 5));
    }
    bonusEndTimeNotifier.value = _bonusEndTime;
    _persistBonus();
  }

  /// Uygulama başladığında kaydedilmiş bonus süresini yükler.
  static Future<void> loadBonus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_storageKey);
      if (str != null) {
        final dt = DateTime.tryParse(str);
        if (dt != null && DateTime.now().isBefore(dt)) {
          _bonusEndTime = dt;
          bonusEndTimeNotifier.value = _bonusEndTime;
          debugPrint('BonusService: Aktif bonus yüklendi, bitiş: $dt');
        } else {
          _bonusEndTime = null;
          bonusEndTimeNotifier.value = null;
          await prefs.remove(_storageKey);
        }
      }
    } catch (e) {
      debugPrint('BonusService: Yükleme hatası: $e');
    }
  }

  /// Bonus bitiş süresini SharedPreferences'a kaydeder.
  static Future<void> _persistBonus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_bonusEndTime != null) {
        await prefs.setString(_storageKey, _bonusEndTime!.toIso8601String());
      } else {
        await prefs.remove(_storageKey);
      }
    } catch (e) {
      debugPrint('BonusService: Kaydetme hatası: $e');
    }
  }

  /// Testler için sıfırlama metodu.
  @visibleForTesting
  static void resetForTesting({DateTime? customEndTime}) {
    _bonusEndTime = customEndTime;
    bonusEndTimeNotifier.value = _bonusEndTime;
  }
}
