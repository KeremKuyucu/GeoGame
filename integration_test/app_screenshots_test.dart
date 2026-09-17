import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:geogame/main.dart' as app;

/// GeoGame Otomatik Ekran Görüntüsü Alma Testi
///
/// Çalıştırmak için:
/// `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_screenshots_test.dart -d <cihaz_id_veya_windows>`
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GeoGame Ekran Görüntülerini Otomatik Yakala',
      (WidgetTester tester) async {
    // 1. Uygulamayı başlat
    app.main();
    await tester.pump(const Duration(milliseconds: 500));

    // 2. Splash ekranının ve yüklemelerin tamamlanmasını bekle
    // pumpAndSettle sonsuz animasyonlarda (CircularProgressIndicator vb.) takılabileceği için
    // belirli aralıklarla pump yaparak ana ekranın açılmasını bekliyoruz.
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump();
      if (find.byIcon(Icons.leaderboard_outlined).evaluate().isNotEmpty) {
        break;
      }
    }

    // Ekranın tam oturması için kısa bir bekleme
    await Future.delayed(const Duration(seconds: 1));
    await tester.pump();

    // 3. Ana Sayfa (Lobi)
    await binding.takeScreenshot('mainlobi');
    // ignore: avoid_print
    print('📸 mainlobi.png kaydedildi');

    // 4. Alt gezinme çubuğundan Liderlik Tablosu (Leaderboard)
    final leaderboardNav = find.byIcon(Icons.leaderboard_outlined);
    if (leaderboardNav.evaluate().isNotEmpty) {
      await tester.tap(leaderboardNav);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();
      await binding.takeScreenshot('leaderboard');
      // ignore: avoid_print
      print('📸 leaderboard.png kaydedildi');
    }

    // 5. Alt gezinme çubuğundan Profil
    final profileNav = find.byIcon(Icons.person_outline);
    if (profileNav.evaluate().isNotEmpty) {
      await tester.tap(profileNav);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();
      await binding.takeScreenshot('profile');
      // ignore: avoid_print
      print('📸 profile.png kaydedildi');
    }

    // 6. Alt gezinme çubuğundan Ayarlar
    final settingsNav = find.byIcon(Icons.settings_outlined);
    if (settingsNav.evaluate().isNotEmpty) {
      await tester.tap(settingsNav);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();
      await binding.takeScreenshot('settings');
      // ignore: avoid_print
      print('📸 settings.png kaydedildi');
    }

    // 7. Tekrar Ana Sayfaya Dön
    final gamesNav = find.byIcon(Icons.videogame_asset_outlined);
    if (gamesNav.evaluate().isNotEmpty) {
      await tester.tap(gamesNav);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();
    }
  });
}
