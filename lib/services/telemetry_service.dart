import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geogame/screens/settings/settings_controller.dart';

class TelemetryService {
  static const String _uidKey = 'app_unique_id';
  static const String _logApiUrl = 'https://keremkk.com.tr/api/logs';
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Uygulama açılışında arka planda çağrılacak telemetri metodu (her açılışta gönderilir)
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. UID kontrolü ve ataması
      String? uid = prefs.getString(_uidKey);
      if (uid == null) {
        uid = const Uuid().v4();
        await prefs.setString(_uidKey, uid);
      }

      // 2. Telemetri açık mı kontrolü
      final isTelemetryEnabled = SettingsController.settings.telemetryEnabled;
      if (!isTelemetryEnabled) return;

      // 3. Açılış telemetri olayını gönder
      await sendEvent('app_opened', uid: uid);
    } catch (e) {
      debugPrint('TelemetryService init hatası: $e');
    }
  }

  /// Genel telemetri olayı gönderme metodu (Genişletilebilir event mimarisi)
  static Future<void> sendEvent(
    String eventName, {
    String? uid,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (!SettingsController.settings.telemetryEnabled) return;

      final prefs = await SharedPreferences.getInstance();
      final effectiveUid = uid ?? prefs.getString(_uidKey) ?? 'unknown';

      final String platform = kIsWeb
          ? 'web'
          : (defaultTargetPlatform == TargetPlatform.windows
              ? 'windows'
              : 'mobile');

      final bodyData = {
        'uid': effectiveUid,
        'timestamp': DateTime.now().toIso8601String(),
        'app': 'geogame',
        'event': eventName,
        'platform': platform,
        if (additionalData != null) ...additionalData,
      };

      final response = await http
          .post(
            Uri.parse(_logApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bodyData),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Telemetri başarıyla gönderildi: $eventName ($effectiveUid)');
      } else {
        debugPrint('⚠️ Telemetri gönderilemedi. Status: ${response.statusCode}');
      }
    } catch (e) {
      // İnternet yoksa, sunucuya ulaşılamazsa veya zaman aşımında sessizce devam et
      debugPrint('Telemetri gönderim hatası: $e');
    }
  }
}
