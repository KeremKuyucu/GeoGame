import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/game_log_service.dart';

class SplashScreenController {
  Future<void> initialize() async {
    await Country.loadCountries();
    AppState.activePool = AppState.filteredCountries;

    await AuthService.checkSession();

    GameLogService.syncPendingLogs();

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppState.version = packageInfo.version;
  }

  /// Ana sayfaya yönlendirir
  void navigateToHome(BuildContext context, Widget destination) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}
