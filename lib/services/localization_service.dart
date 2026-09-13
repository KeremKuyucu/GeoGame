import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/screens/settings/settings_controller.dart';

class Localization {
  static const Map<String, String> languages = {
    'eng': 'English',
    'tur': 'Türkçe',
    'deu': 'Deutsch',
    'spa': 'Español',
    'fra': 'Français',
    'por': 'Português',
    'rus': 'Русский',
    /* Eklenebilecek diller:
    'fin': 'Suomi',
    'jpn': '日本語',
    'ara': 'العربية',
    'bre': 'Brezhoneg',
    'ces': 'Čeština',
    'est': 'Eesti',
    'hrv': 'Hrvatski',
    'hun': 'Magyar',
    'ita': 'Italiano',
    'kor': '한국어',
    'nld': 'Nederlands',
    'per': 'فارسی',
    'pol': 'Polski',
    'slk': 'Slovenčina',
    'srp': 'Srpski',
    'swe': 'Svenska',
    'urd': 'اردو',
    'zho': '中文',
     */
  };

  static const Map<String, String> _iso2ToIso3 = {
    'en': 'eng',
    'tr': 'tur',
    'fi': 'fin',
    'ja': 'jpn',
    'ar': 'ara',
    'br': 'bre',
    'cs': 'ces',
    'de': 'deu',
    'et': 'est',
    'fr': 'fra',
    'hr': 'hrv',
    'hu': 'hun',
    'it': 'ita',
    'ko': 'kor',
    'nl': 'nld',
    'fa': 'per',
    'pl': 'pol',
    'pt': 'por',
    'ru': 'rus',
    'sk': 'slk',
    'es': 'spa',
    'sr': 'srp',
    'sv': 'swe',
    'ur': 'urd',
    'zh': 'zho',
  };

  static Map<String, dynamic>? _localizedStrings;
  static String _currentLanguage = '';
  static List<String> get supportedLanguages => languages.keys.toList();
  static String get currentLanguage => _currentLanguage;

  static String getDisplayName(String iso3Code) =>
      languages[iso3Code] ?? iso3Code;
        
  static Future<void> init() async {
    String language = SettingsController.settings.language;

    if (language.isEmpty) {
      final systemLanguage = PlatformDispatcher.instance.locale.languageCode;

      language = _iso2ToIso3[systemLanguage] ?? 'eng';

      SettingsController.settings.language = language;

      await PreferencesService.saveConfig();
    }

    await changeLanguage(language);
  }

  /// Çalışma anında dil değiştirme
  static Future<void> changeLanguage(String iso3Code) async {
    if (!languages.containsKey(iso3Code)) iso3Code = 'eng';

    try {
      final String jsonString =
          await rootBundle.loadString('assets/lang/$iso3Code.json');
      _localizedStrings = json.decode(jsonString);
      _currentLanguage = iso3Code;
      debugPrint(
          '🌍 Language Loaded: $_currentLanguage (assets/lang/$iso3Code.json)');
    } catch (e) {
      debugPrint('❌ Language File Could Not Be Loaded ($iso3Code): $e');

      // Hata durumunda (örneğin dosya yoksa) İngilizceyi yüklemeyi dene
      if (iso3Code != 'eng') {
        debugPrint('⚠️ Switching to English (fallback)...');
        await changeLanguage('eng');
      } else {
        _localizedStrings = {}; // Hiçbir şey yoksa boş map ata
      }
    }
  }

  /// Çeviri motoru
  static String t(String key, {List<dynamic>? args}) {
    if (_localizedStrings == null) return key;

    final List<String> keys = key.split('.');
    dynamic current = _localizedStrings;

    // JSON içinde ilerle (Map -> Map -> String)
    for (String k in keys) {
      if (current is Map && current.containsKey(k)) {
        current = current[k];
      } else {
        // Anahtar bulunamazsa key'in kendisini döndür (Development için)
        return key;
      }
    }

    // Artık 'current' direkt olarak String değeridir.
    // Eski yapıdaki ['tur'] seçimine gerek kalmadı çünkü dosya zaten Türkçe.
    String text = current.toString();

    // Argümanları yerleştir ({0}, {1} vb.)
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        text = text.replaceAll('{$i}', args[i].toString());
      }
    }

    return text.replaceAll('\\n', '\n');
  }
}
