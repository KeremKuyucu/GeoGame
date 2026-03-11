import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geogame/models/app_context.dart';

class Localization {
  static const Map<String, String> languages = {
    'eng': 'English',
    'tur': 'Türkçe',
    /* Eklenebilecek diller:
    'fin': 'Suomi',
    'jpn': '日本語',
    'ara': 'العربية',
    'bre': 'Brezhoneg',
    'ces': 'Čeština',
    'deu': 'Deutsch',
    'est': 'Eesti',
    'fra': 'Français',
    'hrv': 'Hrvatski',
    'hun': 'Magyar',
    'ita': 'Italiano',
    'kor': '한국어',
    'nld': 'Nederlands',
    'per': 'فارسی',
    'pol': 'Polski',
    'por': 'Português',
    'rus': 'Русский',
    'slk': 'Slovenčina',
    'spa': 'Español',
    'srp': 'Srpski',
    'swe': 'Svenska',
    'urd': 'اردو',
    'zho': '中文',
     */
  };

  static Map<String, dynamic>? _localizedStrings;
  static String _currentLanguage = 'eng';
  static List<String> get supportedLanguages => languages.keys.toList();
  static String get currentLanguage => _currentLanguage;
  static String get currentLanguageName =>
      languages[_currentLanguage] ?? 'English';

  static Future<void> init() async {
    await changeLanguage(AppState.settings.language);
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

  static String getDisplayName(String iso3Code) =>
      languages[iso3Code] ?? iso3Code;
}
