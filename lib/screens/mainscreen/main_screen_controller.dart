import 'package:flutter/material.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/update_checker_service.dart';

/// MainScreen için controller sınıfı
/// Tüm iş mantığı (business logic) burada tutulur
class MainScreenController {
  final BuildContext context;

  MainScreenController(this.context);

  /// Uygulama başlangıcında güncelleme kontrolü yapar
  void checkForUpdates() {
    UpdateService.check(context);
  }

  /// Oyun başlatma işlemi
  /// Eğer filtrelenmiş ülke yoksa uyarı gösterir
  void startGame(GameMetadata metadata) {
    if (AppState.filteredCountries.isEmpty) {
      showNoContinentWarning();
      return;
    }
    Navigator.pushNamed(context, metadata.route);
  }

  /// Kıta seçilmediğinde uyarı SnackBar'ı gösterir
  void showNoContinentWarning() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                Localization.t('settings.no_continent_active'),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: Localization.t('settings.title').toUpperCase(),
          textColor: Colors.white,
          onPressed: () => navigateToSettings(),
        ),
      ),
    );
  }

  /// Ayarlar sayfasına yönlendirir
  void navigateToSettings() {
    AppState.selectedIndex = 3;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  /// Tema durumuna göre arka plan renklerini döndürür
  List<Color> getBackgroundColors(bool isDark) {
    return isDark
        ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
        : [const Color(0xFFF5F7FA), const Color(0xFFC3CFE2)];
  }

  /// Görünüm tipini belirler (Grid veya List)
  bool shouldUseGridLayout(double maxWidth) {
    return maxWidth > 800;
  }
}
