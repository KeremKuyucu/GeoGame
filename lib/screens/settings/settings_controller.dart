import 'package:flutter/material.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/widgets/restart_widget.dart';

class SettingsController {
  static AppSettings settings = AppSettings();
  static GameFilter gameFilter = GameFilter();
  static String get language => settings.language;
  static List<Country> get filteredCountries {
    final f = gameFilter;
    if (AppState.allCountries.isEmpty ||
        (!f.northAmerica &&
            !f.southAmerica &&
            !f.asia &&
            !f.africa &&
            !f.europe &&
            !f.oceania &&
            !f.antarctic)) {
      return [];
    }
    return AppState.allCountries.where((c) {
      if (!f.includeNonUN && !c.isUNMember) return false;
      return (f.europe && c.continents.contains('Europe')) ||
          (f.asia && c.continents.contains('Asia')) ||
          (f.africa && c.continents.contains('Africa')) ||
          (f.oceania && c.continents.contains('Oceania')) ||
          (f.northAmerica && c.continents.contains('North America')) ||
          (f.southAmerica && c.continents.contains('South America')) ||
          (f.antarctic && c.continents.contains('Antarctic'));
    }).toList();
  }

  bool get isAuthenticated => AuthService.isAuthenticated;
  String get userName => AppState.user.name;
  String get userAvatar => AppState.user.avatarUrl;
  bool get isDarkTheme => settings.darkTheme;
  bool get isButtonMode => gameFilter.isButtonMode;
  String get currentLanguage => language;
  bool get isTelemetryEnabled => settings.telemetryEnabled;
  String get appVersion => AppState.version;
  bool get europeEnabled => gameFilter.europe;
  bool get asiaEnabled => gameFilter.asia;
  bool get africaEnabled => gameFilter.africa;
  bool get northAmericaEnabled => gameFilter.northAmerica;
  bool get southAmericaEnabled => gameFilter.southAmerica;
  bool get oceaniaEnabled => gameFilter.oceania;
  bool get antarcticaEnabled => gameFilter.antarctic;
  bool get includeNonUN => gameFilter.includeNonUN;

  Future<void> signOut() => AuthService.signOut();
  Future<void> navigateToEditProfile(BuildContext context) =>
      Navigator.pushNamed(context, '/profile/edit');
  Future<void> navigateToAuth(BuildContext context) =>
      Navigator.pushNamed(context, '/auth');
  void showSnackBar(BuildContext context, String message, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16)));
  Future<void> restartApp(BuildContext context) async {
    AppState.selectedIndex = 0;
    await Localization.init();
    if (context.mounted) RestartWidget.restartApp(context);
  }

  void setButtonMode(bool value) =>
      _save(() => gameFilter.isButtonMode = value);
  void setDarkTheme(bool value) {
    settings.darkTheme = value;
    value
        ? ThemeModeBuilderConfig.setDark()
        : ThemeModeBuilderConfig.setLight();
    PreferencesService.saveConfig();
  }

  void setTelemetryEnabled(bool value) =>
      _save(() => settings.telemetryEnabled = value);
  Future<void> changeLanguage(String code, BuildContext context) async {
    if (code == language) return;
    settings.language = code;
    await PreferencesService.saveConfig();
    await Localization.changeLanguage(code);
    if (context.mounted) await restartApp(context);
  }

  void setEuropeFilter(bool value) =>
      _updatePool(() => gameFilter.europe = value);
  void setAsiaFilter(bool value) => _updatePool(() => gameFilter.asia = value);
  void setAfricaFilter(bool value) =>
      _updatePool(() => gameFilter.africa = value);
  void setNorthAmericaFilter(bool value) =>
      _updatePool(() => gameFilter.northAmerica = value);
  void setSouthAmericaFilter(bool value) =>
      _updatePool(() => gameFilter.southAmerica = value);
  void setOceaniaFilter(bool value) =>
      _updatePool(() => gameFilter.oceania = value);
  void setAntarcticaFilter(bool value) =>
      _updatePool(() => gameFilter.antarctic = value);
  void setIncludeNonUN(bool value) =>
      _updatePool(() => gameFilter.includeNonUN = value);
  static void _save(void Function() update) {
    update();
    PreferencesService.saveConfig();
  }

  static void _updatePool(void Function() update) {
    update();
    AppState.activePool = filteredCountries;
    PreferencesService.saveConfig();
  }
}

class AppSettings {
  bool darkTheme;
  String language;
  bool telemetryEnabled;
  AppSettings(
      {this.darkTheme = true,
      this.language = 'eng',
      this.telemetryEnabled = true});
  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
      darkTheme: map['darkTheme'] ?? true,
      language: map['language']?.toString().isNotEmpty == true
          ? map['language']
          : 'eng',
      telemetryEnabled: map['telemetryEnabled'] ?? true);
  Map<String, dynamic> toMap() => {
        'darkTheme': darkTheme,
        'language': language,
        'telemetryEnabled': telemetryEnabled
      };
}

class GameFilter {
  bool northAmerica,
      southAmerica,
      asia,
      africa,
      europe,
      oceania,
      antarctic,
      includeNonUN,
      isButtonMode;
  GameFilter(
      {this.northAmerica = true,
      this.southAmerica = true,
      this.asia = true,
      this.africa = true,
      this.europe = true,
      this.oceania = true,
      this.antarctic = true,
      this.isButtonMode = true,
      this.includeNonUN = false});
  factory GameFilter.fromMap(Map<String, dynamic> map) => GameFilter(
      northAmerica: map['northAmerica'] ?? true,
      southAmerica: map['southAmerica'] ?? true,
      asia: map['asia'] ?? true,
      africa: map['africa'] ?? true,
      europe: map['europe'] ?? true,
      oceania: map['oceania'] ?? true,
      antarctic: map['antarctic'] ?? true,
      isButtonMode: map['isButtonMode'] ?? true,
      includeNonUN: map['includeNonUN'] ?? false);
  Map<String, dynamic> toMap() => {
        'northAmerica': northAmerica,
        'southAmerica': southAmerica,
        'asia': asia,
        'africa': africa,
        'europe': europe,
        'oceania': oceania,
        'antarctic': antarctic,
        'isButtonMode': isButtonMode,
        'includeNonUN': includeNonUN
      };
}
