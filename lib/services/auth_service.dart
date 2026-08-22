import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/env.dart';
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
          'avatar_url': 'https://robohash.org/${name.hashCode.abs()}',
        },
      );

      if (res.user != null) {
        // Now that we have the uid, update avatar_url with the real uid
        await _supabase.auth.updateUser(
          UserAttributes(data: {
            'full_name': name,
            'avatar_url': 'https://robohash.org/${res.user!.id}',
          }),
        );
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

  /// Google ile Giriş Yap (Native ID Token ve OAuth Fallback destekli)
  static Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            Env.googleWebClientId.isNotEmpty ? Env.googleWebClientId : null,
        clientId:
            Env.googleIosClientId.isNotEmpty ? Env.googleIosClientId : null,
        scopes: const ['email', 'profile'],
      );

      // Önceki oturumu temizle
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı giriş penceresini kapattı / iptal etti
        return Localization.t('auth.error_google_cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        debugPrint('⚠️ ID Token is null from native GoogleSignIn, trying OAuth fallback');
        return await _signInWithOAuthFallback();
      }

      final AuthResponse res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (res.user != null) {
        await syncUserData(res.user!);
        return null;
      }
      return Localization.t('auth.error_login_failed');
    } on AuthException catch (e) {
      debugPrint('AuthException in Google Sign-In: ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Unexpected error in Google Sign-In: $e');
      if (!kIsWeb) {
        return await _signInWithOAuthFallback();
      }
      return Localization.t('auth.error_google_sign_in');
    }
  }

  /// Supabase OAuth tarayıcı tabanlı yönlendirme alternatifi
  static Future<String?> _signInWithOAuthFallback() async {
    try {
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? null
            : 'io.supabase.geogame://login-callback/',
      );
      if (!success) {
        return Localization.t('auth.error_login_failed');
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return Localization.t('auth.error_google_sign_in');
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

      final rawMeta = authUser.userMetadata ?? {};
      final String fallbackName = rawMeta['full_name'] ??
          rawMeta['name'] ??
          authUser.email?.split('@').first ??
          Localization.t('settings.guest');
      final String fallbackAvatar = rawMeta['avatar_url'] ??
          rawMeta['picture'] ??
          'https://robohash.org/${authUser.id}';

      if (profileData != null) {
        AppState.user = UserProfile(
            name: profileData['full_name'] ?? fallbackName,
            avatarUrl: profileData['avatar_url'] ?? fallbackAvatar);
      } else {
        AppState.user = UserProfile(
            name: fallbackName,
            avatarUrl: fallbackAvatar);

        // Yeni Google kaydı için profiles tablosuna da kaydetmeyi dene
        try {
          await _supabase.from('profiles').upsert({
            'uid': authUser.id,
            'full_name': fallbackName,
            'avatar_url': fallbackAvatar,
          });
        } catch (e) {
          debugPrint('Notice: Initial profile upsert: $e');
        }
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
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
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
