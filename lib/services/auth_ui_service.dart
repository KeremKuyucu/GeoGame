// lib/services/auth_ui_service.dart

import 'package:flutter/foundation.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';

/// Auth UI mantığını yöneten servis.
/// Validasyon, form kontrolü ve auth işlemlerini yönetir.
/// AuthService (Supabase işlemleri) ile UI arasında köprü görevi görür.
class AuthUIService {

  // ============================================================================
  // AUTH İŞLEMLERİ (Wrapper)
  // ============================================================================

  /// Google ile giriş işlemi sonucu
  static Future<AuthResult> performGoogleSignIn() async {
    final String? error = await AuthService.signInWithGoogle();

    if (error == null) {
      debugPrint('✅ Google Sign-In successful');
      return AuthResult.success(Localization.t('auth.google_login_success'));
    } else {
      debugPrint('❌ Google Sign-In failed: $error');
      return AuthResult.failure(error);
    }
  }

  // ============================================================================
  // KULLANICI BİLGİLERİ
  // ============================================================================

  /// Kullanıcı giriş yapmış mı
  static bool get isAuthenticated => AuthService.isAuthenticated;

  /// Mevcut kullanıcı adı
  static String get userName => AppState.user.name;

  /// Mevcut kullanıcı avatar URL'si
  static String get userAvatar => AppState.user.avatarUrl;

  /// Oturum kontrolü
  static Future<void> checkSession() async {
    await AuthService.checkSession();
  }

  /// Çıkış yap
  static Future<void> signOut() async {
    await AuthService.signOut();
    debugPrint('👋 User signed out');
  }
}

/// Auth işlemi sonucu
class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult._({required this.isSuccess, required this.message});

  factory AuthResult.success(String message) =>
      AuthResult._(isSuccess: true, message: message);
  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, message: message);
}
