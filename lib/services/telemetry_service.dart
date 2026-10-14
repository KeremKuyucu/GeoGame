import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TelemetryService {
  static const String _uidKey = 'app_unique_id';
  static const String _logApiUrl = 'https://keremkuyucu.com.tr/api/logs';
  static const String _errorLogApiUrl = 'https://keremkuyucu.com.tr/api/error-logs';
  static const Duration _requestTimeout = Duration(seconds: 5);
  static final http.Client _client = http.Client();

  static Future<String> getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      final buildNumber = info.buildNumber;
      return buildNumber.isNotEmpty ? '$version+$buildNumber' : version;
    } catch (e) {
      debugPrint('TelemetryService package_info_plus hatası: $e');
      return 'Version Error';
    }
  }

  static Future<String> getEffectiveUid() async {
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

  static String? _sanitize(dynamic val, {int maxLength = 2000}) {
    if (val == null) return null;
    final str = val.toString();
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}\n...[truncated]';
  }

  static String get platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  /// Uygulama açılışında arka planda çağrılacak telemetri metodu (her açılışta gönderilir)
  static Future<void> init() async {
    try {
      await getAppVersion();

      if (!SettingsController.settings.telemetryEnabled) return;

      await sendEvent('app_opened');
    } catch (e) {
      debugPrint('TelemetryService init hatası: $e');
    }
  }

  /// Genel telemetri olayı gönderme metodu (Genişletilebilir event mimarisi)
  static Future<void> sendEvent(
    String eventName, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (!SettingsController.settings.telemetryEnabled) return;

      final effectiveUid = await getEffectiveUid();
      final effectiveAppVersion = await getAppVersion();

      final bodyData = {
        'uid': effectiveUid,
        'app': 'geogame',
        'app_version': effectiveAppVersion,
        'is_debug': kDebugMode,
        'event': eventName,
        'platform': platformName,
        if (additionalData != null) ...additionalData,
      };

      final response = await _client
          .post(
            Uri.parse(_logApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bodyData),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
            '✅ Telemetri başarıyla gönderildi: $eventName ($effectiveUid)');
      } else {
        debugPrint(
            '⚠️ Telemetri gönderilemedi. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Telemetri gönderim hatası: $e');
    }
  }

  /// Hata kayıtlarını 'https://keremkuyucu.com.tr/api/error-logs' uç noktasına gönderir.
  static Future<void> sendError({
    required String event,
    required String message,
    dynamic stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!SettingsController.settings.telemetryEnabled) return;

      final effectiveUid = await getEffectiveUid();
      final effectiveAppVersion = await getAppVersion();

      final bodyData = {
        'uid': effectiveUid,
        'app': 'geogame',
        'app_version': effectiveAppVersion,
        'is_debug': kDebugMode,
        'event': event,
        'platform': platformName,
        'message': _sanitize(message, maxLength: 3000) ?? message,
        if (stackTrace != null)
          'stackTrace': _sanitize(stackTrace, maxLength: 5000),
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _client
          .post(
            Uri.parse(_errorLogApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bodyData),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Hata kaydı başarıyla iletildi: $event ($effectiveUid)');
      } else {
        debugPrint('⚠️ Hata kaydı iletilemedi. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Hata gönderimi sırasında oluşan hatalar sessizce geçilir (asla recursive çağrı yapılmaz)
      debugPrint('Hata kaydı gönderme hatası: $e');
    }
  }
}
