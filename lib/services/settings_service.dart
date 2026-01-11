// lib/services/settings_service.dart

import 'package:flutter/foundation.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/services/localization_service.dart';

/// Uygulama ayarlarını yöneten servis.
/// Tüm ayar değişiklik mantığı burada, UI settings_screen'de.
class SettingsService {
  // ============================================================================
  // GENEL AYARLAR
  // ============================================================================

  /// Çoktan seçmeli mod değişikliği
  static void setButtonMode(bool value) {
    AppState.filter.isButtonMode = value;
    PreferencesService.saveConfig();
    debugPrint("🎮 Button Mode: $value");
  }

  /// Dark mode değişikliği
  static void setDarkTheme(bool value) {
    AppState.settings.darkTheme = value;
    value ? ThemeModeBuilderConfig.setDark() : ThemeModeBuilderConfig.setLight();
    PreferencesService.saveConfig();
    debugPrint("🌙 Dark Theme: $value");
  }

  /// Dil değişikliği (Uygulama yeniden başlatılmalı)
  static Future<void> changeLanguage(String languageCode) async {
    if (languageCode == AppState.settings.language) return;
    
    AppState.settings.language = languageCode;
    await PreferencesService.saveConfig();
    await Localization.changeLanguage(languageCode);
    debugPrint("🌍 Language changed to: $languageCode");
  }

  // ============================================================================
  // KITA FİLTRELERİ
  // ============================================================================

  /// Avrupa filtresi
  static void setEuropeFilter(bool value) {
    AppState.filter.europe = value;
    _updateActivePool();
  }

  /// Asya filtresi
  static void setAsiaFilter(bool value) {
    AppState.filter.asia = value;
    _updateActivePool();
  }

  /// Afrika filtresi
  static void setAfricaFilter(bool value) {
    AppState.filter.africa = value;
    _updateActivePool();
  }

  /// Kuzey Amerika filtresi
  static void setNorthAmericaFilter(bool value) {
    AppState.filter.northAmerica = value;
    _updateActivePool();
  }

  /// Güney Amerika filtresi
  static void setSouthAmericaFilter(bool value) {
    AppState.filter.southAmerica = value;
    _updateActivePool();
  }

  /// Okyanusya filtresi
  static void setOceaniaFilter(bool value) {
    AppState.filter.oceania = value;
    _updateActivePool();
  }

  /// Antarktika filtresi
  static void setAntarcticaFilter(bool value) {
    AppState.filter.antarctic = value;
    _updateActivePool();
  }

  /// BM üyesi olmayan ülkeler filtresi
  static void setIncludeNonUN(bool value) {
    AppState.filter.includeNonUN = value;
    _updateActivePool();
  }

  /// Aktif havuzu güncelleyip ayarları kaydet
  static void _updateActivePool() {
    AppState.activePool = AppState.filteredCountries;
    PreferencesService.saveConfig();
    debugPrint("🗺️ Active pool updated: ${AppState.activePool.length} countries");
  }

  // ============================================================================
  // FİLTRE BİLGİLERİ (GETTER'LAR)
  // ============================================================================

  /// Mevcut çoktan seçmeli mod durumu
  static bool get isButtonMode => AppState.filter.isButtonMode;

  /// Mevcut dark theme durumu
  static bool get isDarkTheme => AppState.settings.darkTheme;

  /// Mevcut dil kodu
  static String get currentLanguage => AppState.settings.language;

  /// Kıta filtreleri
  static bool get europeEnabled => AppState.filter.europe;
  static bool get asiaEnabled => AppState.filter.asia;
  static bool get africaEnabled => AppState.filter.africa;
  static bool get northAmericaEnabled => AppState.filter.northAmerica;
  static bool get southAmericaEnabled => AppState.filter.southAmerica;
  static bool get oceaniaEnabled => AppState.filter.oceania;
  static bool get antarcticaEnabled => AppState.filter.antarctic;
  static bool get includeNonUN => AppState.filter.includeNonUN;

  /// Aktif ülke sayısı
  static int get activeCountryCount => AppState.activePool.length;

  /// Uygulama versiyonu
  static String get appVersion => AppState.version;

  // ============================================================================
  // TÜM KITALARI TOPLU DEĞİŞTİRME
  // ============================================================================

  /// Tüm kıtaları aç
  static void enableAllContinents() {
    AppState.filter.europe = true;
    AppState.filter.asia = true;
    AppState.filter.africa = true;
    AppState.filter.northAmerica = true;
    AppState.filter.southAmerica = true;
    AppState.filter.oceania = true;
    AppState.filter.antarctic = true;
    _updateActivePool();
  }

  /// Tüm kıtaları kapat
  static void disableAllContinents() {
    AppState.filter.europe = false;
    AppState.filter.asia = false;
    AppState.filter.africa = false;
    AppState.filter.northAmerica = false;
    AppState.filter.southAmerica = false;
    AppState.filter.oceania = false;
    AppState.filter.antarctic = false;
    _updateActivePool();
  }

  /// Belirli kıtaları aç, diğerlerini kapat
  static void setOnlyContinents(List<String> continents) {
    AppState.filter.europe = continents.contains('europe');
    AppState.filter.asia = continents.contains('asia');
    AppState.filter.africa = continents.contains('africa');
    AppState.filter.northAmerica = continents.contains('north_america');
    AppState.filter.southAmerica = continents.contains('south_america');
    AppState.filter.oceania = continents.contains('oceania');
    AppState.filter.antarctic = continents.contains('antarctica');
    _updateActivePool();
  }
}
