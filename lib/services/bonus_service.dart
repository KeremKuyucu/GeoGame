import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2x Puan Bonusu Servisi.
/// Ödüllü reklam izlendiğinde 5 dakikalığına tüm puanları 2x yapar.
/// Birden fazla reklam izlenirse süre stacklenir (+5 dk, maksimum 30 dk tavan).
/// Cihaz saati manipülasyonlarına (saati geriye/ileriye alma) karşı korumalıdır.
/// Süre dolduğunda zamanlayıcı ile otomatik olarak pasife döner ve arayüzü günceller.
class BonusService {
  BonusService._();

  static const String _storageKey = 'geogame_bonus_end_time';
  static const String _lastKnownTimeKey = 'geogame_bonus_last_known_time';

  /// Tek seferlik bonus süresi (5 dakika).
  static const Duration singleBonusDuration = Duration(minutes: 5);

  /// İzin verilen maksimum toplam bonus süresi (30 dakika tavan sınırı).
  static const Duration maxBonusDuration = Duration(minutes: 30);

  static DateTime? _bonusEndTime;
  static Timer? _expiryTimer;
  static DateTime? _lastKnownMemoryTime;

  /// Bonus süresi değiştiğinde dinleyicileri tetiklemek için notifier.
  static final ValueNotifier<DateTime?> bonusEndTimeNotifier =
      ValueNotifier<DateTime?>(null);

  /// Bonusun şu anda aktif olup olmadığını döner.
  static bool get isActive {
    if (_bonusEndTime == null) return false;
    final now = DateTime.now();

    if (_isClockManipulated(now)) {
      _handleClockTampering();
      return false;
    }

    if (now.isBefore(_bonusEndTime!)) {
      _updateLastKnownTime(now);
      return true;
    }

    _handleExpired();
    return false;
  }

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
  /// Zaten aktifse mevcut sürenin üzerine 5 dakika ekler (maksimum [maxBonusDuration] ile sınırlı).
  static void activate() {
    final now = DateTime.now();
    DateTime newEnd;

    if (isActive) {
      newEnd = _bonusEndTime!.add(singleBonusDuration);
    } else {
      newEnd = now.add(singleBonusDuration);
    }

    // Tavan süre kontrolü: Şimdi + 30 dakikadan ileriye gidemez
    final maxAllowed = now.add(maxBonusDuration);
    if (newEnd.isAfter(maxAllowed)) {
      newEnd = maxAllowed;
    }

    _bonusEndTime = newEnd;
    bonusEndTimeNotifier.value = _bonusEndTime;
    _scheduleExpiryTimer();
    _updateLastKnownTime(now);
    _persistBonus();
  }

  /// Bonusu hemen iptal eder ve temizler.
  static Future<void> clearBonus() async {
    _expiryTimer?.cancel();
    _expiryTimer = null;
    _bonusEndTime = null;
    _lastKnownMemoryTime = null;
    bonusEndTimeNotifier.value = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_lastKnownTimeKey);
    } catch (_) {}
  }

  /// Uygulama başladığında kaydedilmiş bonus süresini yükler.
  static Future<void> loadBonus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_storageKey);
      if (str != null) {
        final dt = DateTime.tryParse(str);
        final now = DateTime.now();

        // Geriye alma kontrolü
        final lastKnownStr = prefs.getString(_lastKnownTimeKey);
        final lastKnown =
            lastKnownStr != null ? DateTime.tryParse(lastKnownStr) : null;
        if (lastKnown != null &&
            now.isBefore(lastKnown.subtract(const Duration(minutes: 2)))) {
          debugPrint(
            'BonusService: Saat geriye alınmış tespit edildi, bonus sıfırlandı.',
          );
          await clearBonus();
          return;
        }

        if (dt != null && now.isBefore(dt)) {
          // İleriye alma manipülasyonu engeli: tavan süre ile sınırla
          final maxAllowed = now.add(maxBonusDuration);
          _bonusEndTime = dt.isAfter(maxAllowed) ? maxAllowed : dt;
          bonusEndTimeNotifier.value = _bonusEndTime;
          _scheduleExpiryTimer();
          _updateLastKnownTime(now);
          debugPrint('BonusService: Aktif bonus yüklendi, bitiş: $_bonusEndTime');
        } else {
          await clearBonus();
        }
      }
    } catch (e) {
      debugPrint('BonusService: Yükleme hatası: $e');
    }
  }

  static void _scheduleExpiryTimer() {
    _expiryTimer?.cancel();
    if (_bonusEndTime == null) return;

    final duration = _bonusEndTime!.difference(DateTime.now());
    if (duration > Duration.zero) {
      _expiryTimer = Timer(duration, () {
        _handleExpired();
      });
    }
  }

  static void _handleExpired() {
    if (_bonusEndTime == null) return;
    _bonusEndTime = null;
    bonusEndTimeNotifier.value = null;
    _expiryTimer?.cancel();
    _expiryTimer = null;
    _persistBonus();
  }

  static bool _isClockManipulated(DateTime now) {
    if (_lastKnownMemoryTime != null) {
      // 2 dakikadan fazla geriye gitmişse saat geri çekilmiş demektir
      if (now.isBefore(_lastKnownMemoryTime!.subtract(const Duration(minutes: 2)))) {
        return true;
      }
    }
    return false;
  }

  static void _handleClockTampering() {
    debugPrint(
      '⚠️ BonusService: Cihaz saatinde geriye sarma tespit edildi! Bonus iptal edildi.',
    );
    _bonusEndTime = null;
    bonusEndTimeNotifier.value = null;
    _expiryTimer?.cancel();
    _expiryTimer = null;
    _lastKnownMemoryTime = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_storageKey);
      prefs.remove(_lastKnownTimeKey);
    }).catchError((_) {});
  }

  static void _updateLastKnownTime(DateTime now) {
    _lastKnownMemoryTime = now;
  }

  /// Bonus bitiş süresini SharedPreferences'a kaydeder.
  static Future<void> _persistBonus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_bonusEndTime != null) {
        await prefs.setString(_storageKey, _bonusEndTime!.toIso8601String());
        await prefs.setString(
          _lastKnownTimeKey,
          DateTime.now().toIso8601String(),
        );
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
    _expiryTimer?.cancel();
    _expiryTimer = null;
    _lastKnownMemoryTime = null;
    _bonusEndTime = customEndTime;
    bonusEndTimeNotifier.value = _bonusEndTime;
    if (customEndTime != null && customEndTime.isAfter(DateTime.now())) {
      _updateLastKnownTime(DateTime.now());
    }
  }
}
