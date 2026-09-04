import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geogame/screens/settings/settings_controller.dart';

class LoggingService {
  static const String _uidKey = 'app_unique_id';
  static const String _logApiUrl = 'https://keremkk.com.tr/api/logs';

  /// Uygulama açılışında çağrılacak ana metod
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. UID kontrolü ve ataması
      String? uid = prefs.getString(_uidKey);
      if (uid == null) {
        uid = const Uuid().v4();
        await prefs.setString(_uidKey, uid);
      }

      // 2. Günlük log kontrolü
      final isTelemetryEnabled = SettingsController.settings.telemetryEnabled;
      if (!isTelemetryEnabled) return;

      try {
        final response = await http.post(
          Uri.parse(_logApiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'uid': uid,
            'timestamp': DateTime.now().toIso8601String(),
            'app': 'geogame',
            'event': 'app_opened',
            'platform': kIsWeb
                ? 'web'
                : (defaultTargetPlatform == TargetPlatform.windows
                    ? 'windows'
                    : 'mobile'),
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('Günlük log başarıyla gönderildi: $uid');
        } else {
          debugPrint(
              'Günlük log gönderilemedi. Status: ${response.statusCode}');
        }
      } catch (e) {
        // İnternet yoksa veya sunucuya ulaşılamazsa sessizce hatayı yut
        debugPrint('Log gönderim hatası: $e');
      }
    } catch (e) {
      debugPrint('LoggingService init hatası: $e');
    }
  }
}
