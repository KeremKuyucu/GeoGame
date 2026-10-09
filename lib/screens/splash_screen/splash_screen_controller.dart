import 'package:flutter/material.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/bonus_service.dart';
import 'package:geogame/services/game_log_service.dart';

class SplashScreenController {
  Future<void> initialize() async {
    try {
      await Country.loadCountries();
      AppState.activePool = SettingsController.filteredCountries;

      // İnternet olmasa bile uygulamanın açılışını engellememesi için timeout ve hata koruması
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

      switch (SettingsController.settings.themeMode) {
        case 'dark':
          await ThemeModeBuilderConfig.setDark();
          break;
        case 'light':
          await ThemeModeBuilderConfig.setLight();
          break;
        case 'system':
        default:
          await ThemeModeBuilderConfig.setSystem();
          break;
      }
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
