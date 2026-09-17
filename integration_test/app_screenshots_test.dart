import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:geogame/main.dart' as app;

/// GeoGame Otomatik Ekran Görüntüsü Alma Testi
///
/// Çalıştırmak için:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_screenshots_test.dart -d <cihaz_id_veya_windows>
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GeoGame Ekran Görüntülerini Otomatik Yakala',
      (WidgetTester tester) async {
    // 1. Uygulamayı başlat
    app.main();

    // Splash ekranının tamamlanmasını ve ana sayfanın açılmasını bekle
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 2. Ana Sayfa (Lobi)
    await binding.takeScreenshot('mainlobi');
    await Future.delayed(const Duration(seconds: 1));

    // 3. Alt gezinme çubuğundan Liderlik Tablosu (Leaderboard)
    final leaderboardNav = find.byIcon(Icons.leaderboard_outlined);
    if (leaderboardNav.evaluate().isNotEmpty) {
      await tester.tap(leaderboardNav);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('leaderboard');
    }

    // 4. Alt gezinme çubuğundan Profil
    final profileNav = find.byIcon(Icons.person_outline);
    if (profileNav.evaluate().isNotEmpty) {
      await tester.tap(profileNav);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('profile');
    }

    // 5. Alt gezinme çubuğundan Ayarlar
    final settingsNav = find.byIcon(Icons.settings_outlined);
    if (settingsNav.evaluate().isNotEmpty) {
      await tester.tap(settingsNav);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('settings');
    }

    // 6. Tekrar Ana Sayfaya Dön
    final gamesNav = find.byIcon(Icons.videogame_asset_outlined);
    if (gamesNav.evaluate().isNotEmpty) {
      await tester.tap(gamesNav);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  });
}
