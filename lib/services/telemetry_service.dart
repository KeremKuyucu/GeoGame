import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/auth_service.dart';

class TelemetryService {
  static const String _uidKey = 'app_unique_id';
  static const String _logApiUrl = 'https://keremkk.com.tr/api/logs';
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Aktif UID'yi döndürür:
  /// 1. Supabase'e giriş yapılmışsa doğrudan Supabase kullanıcı UID'si
  /// 2. Giriş yapılmamışsa (misafir) SharedPreferences'taki kalıcı cihaz/misafir ID'si
  static Future<String> getEffectiveUid([String? explicitUid]) async {
    if (explicitUid != null && explicitUid.isNotEmpty) {
      return explicitUid;
    }

    try {
      final supabaseUid = AuthService.currentUserId;
      if (supabaseUid != null && supabaseUid.isNotEmpty) {
        return supabaseUid;
      }
    } catch (e) {
      debugPrint('TelemetryService Supabase UID alınamadı: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    String? localUid = prefs.getString(_uidKey);
    if (localUid == null) {
      localUid = const Uuid().v4();
      await prefs.setString(_uidKey, localUid);
    }
    return localUid;
  }

  /// Uygulama açılışında arka planda çağrılacak telemetri metodu (her açılışta gönderilir)
  static Future<void> init() async {
    try {
      final isTelemetryEnabled = SettingsController.settings.telemetryEnabled;
      if (!isTelemetryEnabled) return;

      final uid = await getEffectiveUid();
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

      final effectiveUid = await getEffectiveUid(uid);

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
