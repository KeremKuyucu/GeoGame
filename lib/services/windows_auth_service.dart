import 'dart:io';
import 'package:flutter/foundation.dart';

/// Windows platformunda Supabase OAuth deep linking (`io.supabase.geogame://`)
/// protokolünün Windows Kayıt Defteri'ne (Registry) kaydedilmesini sağlar.
class WindowsAuthService {
  static const String customScheme = 'io.supabase.geogame';

  /// Windows üzerinde `io.supabase.geogame://` URI şemasını mevcut çalışan exe'ye kaydeder.
  /// Bu sayede Google OAuth tarayıcıdan uygulamaya başarıyla döner.
  static Future<void> registerProtocolHandler() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) return;

    try {
      final exePath = Platform.resolvedExecutable;
      if (exePath.isEmpty || !exePath.endsWith('.exe')) return;

      final key = r'HKCU\Software\Classes\' + customScheme;

      // 1. Ana anahtar ve açıklama
      await Process.run('reg', [
        'add',
        key,
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        'URL:GeoGame Protocol',
        '/f',
      ]);

      // 2. "URL Protocol" boş değeri
      await Process.run('reg', [
        'add',
        key,
        '/v',
        'URL Protocol',
        '/t',
        'REG_SZ',
        '/d',
        '',
        '/f',
      ]);

      // 3. DefaultIcon
      await Process.run('reg', [
        'add',
        '$key\\DefaultIcon',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        '$exePath,0',
        '/f',
      ]);

      // 4. shell\open\command
      await Process.run('reg', [
        'add',
        '$key\\shell\\open\\command',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath" "%1"',
        '/f',
      ]);

      debugPrint('✅ Windows URL Protocol handler registered for: $exePath');
    } catch (e) {
      debugPrint('⚠️ Failed to register Windows URL protocol: $e');
    }
  }
}
