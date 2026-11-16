import 'dart:ui';

/// Uygulama genel ayarlarını (tema, dil, telemetri) temsil eden model
class AppSettings {
  String themeMode; // 'system', 'light', 'dark'
  String language;
  bool telemetryEnabled;

  /// Geriye dönük uyumluluk ve anlık kontrol için darkTheme:
  bool get darkTheme {
    if (themeMode == 'dark') return true;
    if (themeMode == 'light') return false;
    // 'system' varsayılanında cihazın parlaklığına bakar:
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }

  set darkTheme(bool value) {
    themeMode = value ? 'dark' : 'light';
  }

  AppSettings({
    String themeMode = 'system',
    bool? darkTheme,
    this.language = '',
    this.telemetryEnabled = true,
  }) : themeMode =
            darkTheme != null ? (darkTheme ? 'dark' : 'light') : themeMode;

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    String mode = 'system';
    if (map['themeMode'] != null && map['themeMode'].toString().isNotEmpty) {
      mode = map['themeMode'].toString();
    } else if (map['theme'] != null && map['theme'].toString().isNotEmpty) {
      mode = map['theme'].toString();
    } else if (map['darkTheme'] != null) {
      mode = map['darkTheme'] == true ? 'dark' : 'light';
    }

    return AppSettings(
      themeMode: mode,
      language: map['language']?.toString() ?? '',
      telemetryEnabled: map['telemetryEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode,
        'language': language,
        'telemetryEnabled': telemetryEnabled,
      };
}
