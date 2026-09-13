import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/game_log_service.dart';

class SplashScreenController {
  Future<void> initialize() async {
    await Country.loadCountries();
    
    AppState.activePool = SettingsController.filteredCountries;

    await AuthService.checkSession();

    GameLogService.syncPendingLogs();
  }

  /// Ana sayfaya yönlendirir
  void navigateToHome(BuildContext context, Widget destination) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}
