import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/settings_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/restart_widget.dart';

/// Settings için controller
class SettingsController {
  /// Kullanıcı giriş yapmış mı?
  bool get isAuthenticated => AuthService.isAuthenticated;

  /// Kullanıcı bilgileri
  String get userName => AppState.user.name;
  String get userAvatar => AppState.user.avatarUrl;

  /// Tema bilgisi
  bool get isDarkTheme => SettingsService.isDarkTheme;

  /// Çoktan seçmeli mod
  bool get isButtonMode => SettingsService.isButtonMode;

  /// Dil bilgisi
  String get currentLanguage => SettingsService.currentLanguage;

  /// Versiyon bilgisi
  String get appVersion => SettingsService.appVersion;

  /// Kıta filtreleri
  bool get europeEnabled => SettingsService.europeEnabled;
  bool get asiaEnabled => SettingsService.asiaEnabled;
  bool get africaEnabled => SettingsService.africaEnabled;
  bool get northAmericaEnabled => SettingsService.northAmericaEnabled;
  bool get southAmericaEnabled => SettingsService.southAmericaEnabled;
  bool get oceaniaEnabled => SettingsService.oceaniaEnabled;
  bool get antarcticaEnabled => SettingsService.antarcticaEnabled;
  bool get includeNonUN => SettingsService.includeNonUN;

  /// Çıkış yap
  Future<void> signOut() async {
    await AuthService.signOut();
  }

  /// Profil düzenleme sayfasına git
  Future<void> navigateToEditProfile(BuildContext context) async {
    await Navigator.pushNamed(context, '/profile/edit');
  }

  /// Auth sayfasına git
  Future<void> navigateToAuth(BuildContext context) async {
    await Navigator.pushNamed(context, '/auth');
  }

  /// Snackbar göster
  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Uygulamayı yeniden başlat
  Future<void> restartApp(BuildContext context) async {
    AppState.selectedIndex = 0;
    await Localization.init(userPref: currentLanguage);
    if (context.mounted) {
      RestartWidget.restartApp(context);
    }
  }

  /// Çoktan seçmeli mod değiştir
  void setButtonMode(bool value) {
    SettingsService.setButtonMode(value);
  }

  /// Tema değiştir
  void setDarkTheme(bool value) {
    SettingsService.setDarkTheme(value);
  }

  /// Dil değiştir
  Future<void> changeLanguage(String languageCode, BuildContext context) async {
    if (languageCode != currentLanguage) {
      await SettingsService.changeLanguage(languageCode);
      if (context.mounted) {
        await restartApp(context);
      }
    }
  }

  /// Kıta filtrelerini değiştir
  void setEuropeFilter(bool value) => SettingsService.setEuropeFilter(value);
  void setAsiaFilter(bool value) => SettingsService.setAsiaFilter(value);
  void setAfricaFilter(bool value) => SettingsService.setAfricaFilter(value);
  void setNorthAmericaFilter(bool value) =>
      SettingsService.setNorthAmericaFilter(value);
  void setSouthAmericaFilter(bool value) =>
      SettingsService.setSouthAmericaFilter(value);
  void setOceaniaFilter(bool value) => SettingsService.setOceaniaFilter(value);
  void setAntarcticaFilter(bool value) =>
      SettingsService.setAntarcticaFilter(value);
  void setIncludeNonUN(bool value) => SettingsService.setIncludeNonUN(value);
}
