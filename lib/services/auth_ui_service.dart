// lib/services/auth_ui_service.dart

import 'package:flutter/foundation.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/name_filter_service.dart';

/// Auth UI mantığını yöneten servis.
/// Validasyon, form kontrolü ve auth işlemlerini yönetir.
/// AuthService (Supabase işlemleri) ile UI arasında köprü görevi görür.
class AuthUIService {
  // ============================================================================
  // FORM VALIDASYON
  // ============================================================================

  /// Email formatını kontrol eder
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Şifre gücünü kontrol eder
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// İsim kontrolü
  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  /// Login form validasyonu
  static String? validateLoginForm(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return Localization.t('common.field_required');
    }
    if (!isValidEmail(email)) {
      return Localization.t('auth.invalid_email');
    }
    return null; // Valid
  }

  /// Register form validasyonu
  static String? validateRegisterForm({
    required String email,
    required String password,
    required String name,
    required String confirmPassword,
  }) {
    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        confirmPassword.isEmpty) {
      return Localization.t('common.field_required');
    }
    if (!isValidEmail(email)) {
      return Localization.t('auth.invalid_email');
    }
    if (!isValidName(name)) {
      return Localization.t('auth.name_too_short');
    }
    final nameFilterError = NameFilterService.validate(name);
    if (nameFilterError != null) {
      return Localization.t('auth.$nameFilterError');
    }
    if (!isValidPassword(password)) {
      return Localization.t('auth.password_too_short');
    }
    if (password != confirmPassword) {
      return Localization.t('auth.password_mismatch');
    }
    return null; // Valid
  }

  /// Şifre sıfırlama email validasyonu
  static String? validateResetEmail(String email) {
    if (email.isEmpty) {
      return Localization.t('common.field_required');
    }
    if (!isValidEmail(email)) {
      return Localization.t('auth.invalid_email');
    }
    return null;
  }

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
