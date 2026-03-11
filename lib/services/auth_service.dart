import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/models/app_context.dart';

import 'package:geogame/services/localization_service.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<String?> signIn(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        await syncUserData(res.user!);
        return null;
      }
      return Localization.t('auth.error_login_failed');
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return Localization.t('auth.error_unknown', args: [e.toString()]);
    }
  }

  static Future<String?> signUp(
      String email, String password, String name) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'avatar_url': 'https://robohash.org/kaplan.png?set=set4',
        },
      );

      if (res.user != null) {
        await syncUserData(res.user!);
        return null;
      }
      return Localization.t('auth.error_register_failed');
    } on AuthException catch (e) {
      debugPrint('Auth Error: ${e.message}');
      if (e.message.contains('Database error')) {
        return Localization.t('auth.error_db_profile');
      }
      return e.message;
    } catch (e) {
      return Localization.t('auth.error_unknown', args: [e.toString()]);
    }
  }

  static Future<void> syncUserData(User authUser) async {
    try {
      var profileData = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('uid', authUser.id)
          .maybeSingle();

      if (profileData == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        profileData = await _supabase
            .from('profiles')
            .select('full_name, avatar_url')
            .eq('uid', authUser.id)
            .maybeSingle();
      }

      if (profileData != null) {
        AppState.user = UserProfile(
            name: profileData['full_name'] ?? Localization.t('settings.guest'),
            avatarUrl: profileData['avatar_url'] ??
                'https://robohash.org/${authUser.id}.png?set=set4');
      } else {
        AppState.user = UserProfile(
            name: authUser.userMetadata?['full_name'] ??
                Localization.t('settings.guest'),
            avatarUrl: authUser.userMetadata?['avatar_url'] ??
                'https://robohash.org/${authUser.id}.png?set=set4');
      }

      debugPrint('✅ Profile sync complete: ${AppState.user.name}');
    } catch (e) {
      debugPrint('❌ Profile Sync Error: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Supabase exit error: $e');
    }
    AppState.user = UserProfile.anonymous();
  }

  static bool get isAuthenticated => _supabase.auth.currentUser != null;
  static String? get currentUserId => _supabase.auth.currentUser?.id;
  static User? get currentUser => _supabase.auth.currentUser;

  static Future<void> checkSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await syncUserData(session.user);
    }
  }

  static Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return Localization.t('auth.error_unexpected', args: [e.toString()]);
    }
  }

  static Future<String?> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return Localization.t('auth.error_unexpected', args: [e.toString()]);
    }
  }

  static Future<String?> updateEmail(String newEmail) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(email: newEmail));
      return null; // Başarılı
    } on AuthException catch (e) {
      // Özel hata mesajı temizleme (isteğe bağlı)
      if (e.message.contains('already registered')) {
        return Localization.t('auth.error_email_in_use');
      }
      return e.message;
    } catch (e) {
      return Localization.t('auth.error_unexpected', args: [e.toString()]);
    }
  }

  static Future<String?> updateProfileMetadata(
      {required String name, required String avatarUrl}) async {
    try {
      // Basic security validation for avatarUrl
      final uri = Uri.tryParse(avatarUrl);
      if (uri == null || !uri.hasAbsolutePath || !uri.isScheme('https')) {
        return Localization.t('auth.error_invalid_avatar');
      }

      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': name, 'avatar_url': avatarUrl}),
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return Localization.t('auth.error_unexpected', args: [e.toString()]);
    }
  }
}
