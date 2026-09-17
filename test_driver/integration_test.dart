import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

/// Flutter Integration Test Ekran Görüntüsü Sürücüsü
/// `binding.takeScreenshot('isim')` çağrıldığında tetiklenir ve
/// PNG dosyasını doğrudan `screenshots/` klasörüne kaydeder.
Future<void> main() async {
  final screenshotsDir = Directory('screenshots');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  await integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, dynamic>? args,
    ]) async {
      final sanitizedName = screenshotName.endsWith('.png')
          ? screenshotName
          : '$screenshotName.png';
      final file = File('screenshots/$sanitizedName');
      await file.writeAsBytes(screenshotBytes);
      // ignore: avoid_print
      print('📸 [Screenshot Kaydedildi]: screenshots/$sanitizedName (${screenshotBytes.length} bayt)');
      return true;
    },
  );
}
