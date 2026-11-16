import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geogame/models/app_settings.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold_controller.dart';
import 'package:geogame/services/ad_service.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/widgets/feedback_dialog.dart';
import 'package:geogame/widgets/restart_widget.dart';

export 'package:geogame/models/app_settings.dart';
export 'package:geogame/models/countries.dart' show GameFilter;

class SettingsController {
  static AppSettings settings = AppSettings();
  static GameFilter gameFilter = GameFilter();
  static String get language => settings.language;
  static List<Country> get filteredCountries => Country.filter(gameFilter);

  bool get isAuthenticated => AuthService.isAuthenticated;
  String get userName => AuthService.user.name;
  String get userAvatar => AuthService.user.avatarUrl;
  String get themeMode => settings.themeMode;
  bool get isDarkTheme => settings.darkTheme;
  bool get isButtonMode => gameFilter.isButtonMode;
  String get currentLanguage => language;
  bool get isTelemetryEnabled => settings.telemetryEnabled;

  bool get europeEnabled => gameFilter.europe;
  bool get asiaEnabled => gameFilter.asia;
  bool get africaEnabled => gameFilter.africa;
  bool get northAmericaEnabled => gameFilter.northAmerica;
  bool get southAmericaEnabled => gameFilter.southAmerica;
  bool get oceaniaEnabled => gameFilter.oceania;
  bool get antarcticaEnabled => gameFilter.antarctic;
  bool get includeNonUN => gameFilter.includeNonUN;

  /// Tema durumuna göre arka plan renklerini döndürür (Tüm ekranlarla birebir uyumlu)
  List<Color> getBackgroundColors(bool isDark) {
    return isDark
        ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
        : [const Color(0xFFF5F7FA), const Color(0xFFC3CFE2)];
  }

  Future<void> signOut() => AuthService.signOut();
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
    MainScaffoldController.selectedIndex = 0;
    await Localization.init();
    if (context.mounted) RestartWidget.restartApp(context);
  }

  void setButtonMode(bool value) =>
      _save(() => gameFilter.isButtonMode = value);


  static Future<void> applyTheme([String? mode]) async {
    final theme = mode ?? settings.themeMode;
    try {
      switch (theme) {
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
      debugPrint('⚠️ applyTheme hatası: $e');
    }
  }

  Future<void> setThemeMode(String value) async {
    settings.themeMode = value;
    await applyTheme(value);
    await PreferencesService.saveConfig();
  }

  void setDarkTheme(bool value) {
    setThemeMode(value ? 'dark' : 'light');
  }

  void setTelemetryEnabled(bool value) =>
      _save(() => settings.telemetryEnabled = value);

  Future<void> changeLanguage(String code, BuildContext context) async {
    if (code == language) return;
    settings.language = code;
    await PreferencesService.saveConfig();
    await Localization.loadLanguage(code);
    if (context.mounted) await restartApp(context);
  }

  void setEuropeFilter(bool value) => _updatePool(() => gameFilter.europe = value);
  void setAsiaFilter(bool value) => _updatePool(() => gameFilter.asia = value);
  void setAfricaFilter(bool value) => _updatePool(() => gameFilter.africa = value);
  void setNorthAmericaFilter(bool value) => _updatePool(() => gameFilter.northAmerica = value);
  void setSouthAmericaFilter(bool value) => _updatePool(() => gameFilter.southAmerica = value);
  void setOceaniaFilter(bool value) => _updatePool(() => gameFilter.oceania = value);
  void setAntarcticaFilter(bool value) => _updatePool(() => gameFilter.antarctic = value);
  void setIncludeNonUN(bool value) => _updatePool(() => gameFilter.includeNonUN = value);

  static void _save(void Function() update) {
    update();
    PreferencesService.saveConfig();
  }

  static void _updatePool(void Function() update) {
    update();
    Country.updateActivePool(gameFilter);
    PreferencesService.saveConfig();
  }

  // --- Sürüm ve Gizlilik Bilgileri ---
  String appVersion = '';
  bool isPrivacyOptionsRequired = false;

  Future<String> loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = 'GeoGame v${info.version}';
    } catch (e) {
      debugPrint('Error loading app version: $e');
      appVersion = 'GeoGame';
    }
    return appVersion;
  }

  Future<bool> checkPrivacyOptionsRequired() async {
    isPrivacyOptionsRequired = await AdService.isPrivacyOptionsRequired();
    return isPrivacyOptionsRequired;
  }

  void showAdPreferences(BuildContext context) {
    AdService.showPrivacyOptionsForm(context);
  }

  // --- Oturum Yönetimi ---
  Future<void> handleSignOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final successMessage = Localization.t('auth.logout_success');
    await signOut();
    messenger.showSnackBar(
      SnackBar(
        content: Text(successMessage),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- Harici Bağlantılar ---
  Future<void> launchPlayStore() async {
    final Uri marketUri =
        Uri.parse('market://details?id=com.keremkuyucu.geogame');
    final Uri webUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.keremkuyucu.geogame');

    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Play Store linki açılamadı: $e');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Link açılamadı: $urlString');
    }
  }

  Future<void> openWebsite() => launchURL('https://geogame.keremkuyucu.com.tr');
  Future<void> openGitHub() => launchURL('https://github.com/KeremKuyucu/GeoGame');

  void showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const FeedbackDialog(),
    );
  }

  // --- Telemetri İşlemleri ---
  Future<bool?> showTelemetryConfirmDialog(BuildContext context, bool isDark) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          Localization.t('settings.telemetry_dialog_title'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          Localization.t('settings.telemetry_dialog_message'),
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              Localization.t('settings.telemetry_cancel'),
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(Localization.t('settings.telemetry_disable')),
          ),
        ],
      ),
    );
  }

  Future<void> handleTelemetryChange(
      BuildContext context, bool targetValue, bool isDark) async {
    if (!targetValue) {
      final shouldDisable = await showTelemetryConfirmDialog(context, isDark);
      if (shouldDisable != true) return;
    }
    setTelemetryEnabled(targetValue);
  }
}
