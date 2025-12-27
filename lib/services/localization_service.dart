// lib/services/localization_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Localization {
  // ARTIK DEĞİŞTİ: Listeyi kod olarak tutuyoruz.
  static const List<String> supportedLanguages = ['en', 'tr'];

  // UI'da göstermek istersen diye kod -> isim eşleşmesi (Opsiyonel)
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'tr': 'Türkçe',
  };

  static Map<String, dynamic>? _localizedStrings;

  // Varsayılan dil kodu artık 'en'
  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;

  // UI'da şu anki dilin görünen adını almak istersen:
  static String get currentLanguageName => _languageNames[_currentLanguage] ?? 'English';

  static Future<void> init({String? userPref, String? deviceLocale}) async {
    String targetLang;

    // 1. Kullanıcı tercihi varsa (artık 'tr' veya 'en' olarak gelmeli)
    if (userPref != null && supportedLanguages.contains(userPref)) {
      targetLang = userPref;
    }
    // 2. Cihaz dili (genelde 'tr_TR' gelir, biz başındaki 'tr'ye bakarız)
    else if (deviceLocale != null && deviceLocale.startsWith('tr')) {
      targetLang = 'tr';
    }
    // 3. Varsayılan
    else {
      targetLang = 'en';
    }

    await changeLanguage(targetLang);
  }

  static Future<void> changeLanguage(String languageCode) async {
    // Eğer dil zaten buysa ve veri yüklüyse tekrar işlem yapma
    if (_localizedStrings != null && _currentLanguage == languageCode) {
      return;
    }

    // Desteklenmeyen bir kod gelirse varsayılana dön
    if (!supportedLanguages.contains(languageCode)) {
      languageCode = 'en';
    }

    try {
      // JSON dosyasını her dil değişiminde tekrar okumaya gerek olmayabilir
      // ama yapıyı bozmamak için senin mantığı koruyorum:
      String jsonString = await rootBundle.loadString('assets/dil.json');
      _localizedStrings = json.decode(jsonString);

      _currentLanguage = languageCode; // Artık kodu atıyoruz (tr, en)

      debugPrint('Dil kodu yüklendi: $_currentLanguage');
    } catch (e) {
      debugPrint('Localization Hatası: $e');
      _localizedStrings = {};
    }
  }

  static String t(String key, {List<dynamic>? args}) {
    if (_localizedStrings == null) return key;

    List<String> keys = key.split('.');
    dynamic current = _localizedStrings;

    // Hiyerarşide ilerle
    for (String k in keys) {
      if (current is Map && current.containsKey(k)) {
        current = current[k];
      } else {
        return key;
      }
    }

    String metin = "";

    // BURASI DEĞİŞTİ: Artık dönüşüm yapmıyoruz, direkt _currentLanguage kullanıyoruz.
    if (current is Map) {
      // Önce şu anki dil kodu (tr), yoksa (en), o da yoksa ilk değer
      metin = current[_currentLanguage]?.toString() ??
          current['en']?.toString() ??
          current.values.first.toString();
    } else if (current is String) {
      metin = current;
    } else {
      return key;
    }

    // Parametreleri işle ({0}, {1} vb.)
    if (args != null && args.isNotEmpty) {
      for (int i = 0; i < args.length; i++) {
        metin = metin.replaceAll('{$i}', args[i].toString());
      }
    }

    return metin.replaceAll('\\n', '\n');
  }

  static String getDisplayName(String code) {
    return _languageNames[code] ?? code;
  }
}