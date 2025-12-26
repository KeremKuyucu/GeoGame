// lib/services/preferences_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geogame/models/app_context.dart';

class PreferencesService {
  static const String _storageKey = 'geogame_config';

  static Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      if (jsonString == null) {
        await saveConfig();
        return;
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);
      print(data);
      // Global State'i güncelle
      AppState.settings = AppSettings.fromMap(data);
      AppState.filter = GameFilter.fromMap(data);

      debugPrint("✅ Ayarlar ve tercihler yüklendi.");
    } catch (e) {
      debugPrint('❌ Config Yükleme Hatası: $e');
      // Hata durumunda varsayılan değerlerle devam edilir (AppState zaten varsayılanla başlar)
    }
  }

  /// 💾 Ayar değişikliğinde çalışır (Tema değişti, dil değişti vb.)
  static Future<void> saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> data = {
        ...AppState.settings.toMap(),
        ...AppState.filter.toMap(),
        // ...AppState.stats.toMap(),
      };

      await prefs.setString(_storageKey, jsonEncode(data));
      // debugPrint("💾 Ayarlar diske yazıldı.");
    } catch (e) {
      debugPrint('❌ Ayar Kayıt Hatası: $e');
    }
  }
}