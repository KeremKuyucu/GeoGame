import 'package:flutter/services.dart';

/// Oyun içi titreşim ve dokunsal geri bildirim (Haptic Feedback) servisi.
class HapticService {
  /// Doğru cevap / başarı durumunda hafif ve tatmin edici titreşim
  static void correct() {
    HapticFeedback.lightImpact();
  }

  /// Yanlış cevap / hata durumunda belirgin ve uyarıcı titreşim
  static void wrong() {
    HapticFeedback.heavyImpact();
  }

  /// Pas geçme / ara aşamalar için orta düzey titreşim
  static void pass() {
    HapticFeedback.mediumImpact();
  }

  /// Buton veya ülke seçimi dokunuşu için mikro geri bildirim
  static void selection() {
    HapticFeedback.selectionClick();
  }
}
