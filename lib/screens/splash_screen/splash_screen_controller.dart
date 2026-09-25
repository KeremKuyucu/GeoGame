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
    await Country.loadCountries();
    AppState.activePool = SettingsController.filteredCountries;

    await AuthService.checkSession();
    await BonusService.loadBonus();
    GameLogService.syncPendingLogs();

    if (SettingsController.settings.darkTheme) {
      ThemeModeBuilderConfig.setDark();
    } else {
      ThemeModeBuilderConfig.setLight();
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
