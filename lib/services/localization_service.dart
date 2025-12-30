import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Localization {

  static const Map<String, String> languages = {
    'eng': 'English',
    'tur': 'Türkçe',
    /* Eklenecek dil listesi:
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
  static const Map<String, String> _deviceIsoMap = {
    'en': 'eng',
    'tr': 'tur',
    /* Cihaz eşleme listesi:
    'ar': 'ara',
    'cs': 'ces',
    'de': 'deu',
    'et': 'est',
    'fi': 'fin',
    'fr': 'fra',
    'hr': 'hrv',
    'hu': 'hun',
    'it': 'ita',
    'ja': 'jpn',
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
    */
  };

  static Map<String, dynamic>? _localizedStrings;
  static String _currentLanguage = 'eng';
  static List<String> get supportedLanguages => languages.keys.toList();
  static String get currentLanguage => _currentLanguage;
  static String get currentLanguageName => languages[_currentLanguage] ?? 'English';

  static Future<void> init({String? userPref, String? deviceLocale}) async {
    String target;

    if (userPref != null && languages.containsKey(userPref)) {
      target = userPref;
    } else if (deviceLocale != null && _deviceIsoMap.containsKey(deviceLocale)) {
      target = _deviceIsoMap[deviceLocale]!;
    } else {
      target = 'eng';
    }

    await changeLanguage(target);
  }

  /// Çalışma anında dil değiştirme
  static Future<void> changeLanguage(String iso3Code) async {
    if (!languages.containsKey(iso3Code)) iso3Code = 'eng';

    try {
      // DİKKAT: Dosyaların 'assets/lang/tur.json' formatında olduğundan emin olun.
      final String jsonString = await rootBundle.loadString('assets/lang/$iso3Code.json');
      _localizedStrings = json.decode(jsonString);
      _currentLanguage = iso3Code;
      debugPrint("🌍 Dil Yüklendi: $_currentLanguage (assets/lang/$iso3Code.json)");
    } catch (e) {
      debugPrint("❌ Dil Dosyası Yüklenemedi ($iso3Code): $e");

      // Hata durumunda (örneğin dosya yoksa) İngilizceyi yüklemeyi dene
      if (iso3Code != 'eng') {
        debugPrint("⚠️ İngilizceye (fallback) geçiliyor...");
        await changeLanguage('eng');
      } else {
        _localizedStrings = {}; // Hiçbir şey yoksa boş map ata
      }
    }
  }
  /// Çeviri motoru
  static String t(String key, {List<dynamic>? args}) {
    if (_localizedStrings == null) return key;

    List<String> keys = key.split('.');
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

  static String getDisplayName(String iso3Code) => languages[iso3Code] ?? iso3Code;
}