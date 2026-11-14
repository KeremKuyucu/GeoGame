import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/ad_service.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/bonus_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/telemetry_service.dart';

class SplashScreenController {
  Future<void> initialize() async {
    try {
      AdService.initialize();
      TelemetryService.init();
      AuthService.initAuthStateListener();

      await Future.wait([
        Country.loadCountries(),
        Localization.init(),
      ]);
      AppState.activePool = SettingsController.filteredCountries;

      // timeout ve hata koruması
      await AuthService.checkSession().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('⚠️ AuthService.checkSession timeout (offline mode)');
        },
      ).catchError((e) {
        debugPrint('⚠️ AuthService.checkSession error: $e');
      });

      await BonusService.loadBonus().catchError((e) {
        debugPrint('⚠️ BonusService.loadBonus error: $e');
      });

      // Arka planda log senkronizasyonu (açılışı bloklamaz)
      GameLogService.syncPendingLogs().catchError((e) {
        debugPrint('⚠️ GameLogService.syncPendingLogs error: $e');
      });
    } catch (e) {
      debugPrint('❌ SplashScreenController initialize error: $e');
    }
  }

  /// Ana sayfaya yönlendirir
  void navigateToHome(BuildContext context, Widget destination) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}
