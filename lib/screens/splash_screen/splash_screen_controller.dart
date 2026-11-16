import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/ad_service.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/bonus_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/telemetry_service.dart';
import 'package:geogame/services/preferences_service.dart';


class SplashScreenController {
  Future<void> initialize() async {
    try {
      await PreferencesService.loadConfig();
      await Country.loadCountries(SettingsController.gameFilter);
      await Localization.init();
      AdService.initialize();
      TelemetryService.init();
      AuthService.initAuthStateListener();
      AuthService.restoreSessionSync();
      await BonusService.loadBonus();
      await SettingsController.applyTheme();
      GameLogService.syncPendingLogs();
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
