import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/services/telemetry_service.dart';

void main() {
  group('TelemetryService Platform Detection Tests', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('defaultTargetPlatform override ile tüm platformlar doğru ayrıştırılmalı', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(TelemetryService.platformName, 'android');

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(TelemetryService.platformName, 'ios');

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(TelemetryService.platformName, 'windows');

      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(TelemetryService.platformName, 'macos');

      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(TelemetryService.platformName, 'linux');

      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(TelemetryService.platformName, 'fuchsia');
    });

    test('platformName asla genel "mobile" stringi döndürmemeli', () {
      for (final platform in TargetPlatform.values) {
        debugDefaultTargetPlatformOverride = platform;
        expect(TelemetryService.platformName, isNot('mobile'));
      }
    });
  });
}
