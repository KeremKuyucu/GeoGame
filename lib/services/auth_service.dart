import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/models/user_profile.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/localization_service.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // --- Global Kullanıcı Durumu (State) ---
  static final ValueNotifier<UserProfile> userNotifier =
      ValueNotifier<UserProfile>(UserProfile.anonymous());

  static UserProfile get user => userNotifier.value;
  static set user(UserProfile profile) {
    userNotifier.value = profile;
  }

  static String get redirectUrl {
    if (kIsWeb) {
      return '${Uri.base.origin}/';
    }
    return 'com.keremkuyucu.geogame://login-callback/';
  }

  /// Google ile Giriş Yap (Supabase OAuth)
  static Future<String?> signInWithGoogle() async {
    try {
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );

      if (!success) {
        return Localization.t('auth.error_login_failed');
      }
      return null;
    } on AuthException catch (e) {
      debugPrint('AuthException in Google Sign-In: ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Google Sign-In Exception: $e');
      return Localization.t('auth.error_google_sign_in');
    }
  }

  static void syncUserData(User authUser) {
    final meta = authUser.userMetadata ?? {};
    final String name =
        (meta['full_name'] ?? meta['name'])?.toString().trim() ??
            Localization.t('settings.guest');
    final String avatar =
        (meta['avatar_url'] ?? meta['picture'])?.toString().trim() ??
            'https://robohash.org/${authUser.id}';

    user = UserProfile(
      name: name,
      avatarUrl: avatar,
    );
  }

  static void initAuthStateListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      debugPrint('🔔 Supabase Auth State Changed: $event');

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.initialSession ||
          event == AuthChangeEvent.userUpdated) {
        if (session?.user != null) {
          syncUserData(session!.user);
          GameLogService.syncPendingLogs();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        user = UserProfile.anonymous();
      }
    });
  }

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Supabase exit error: $e');
    }
    user = UserProfile.anonymous();
  }

  static void restoreSessionSync() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      syncUserData(user);
    }
  }

  static bool get isAuthenticated => _supabase.auth.currentUser != null;
  static String? get currentUserId => _supabase.auth.currentUser?.id;
  static User? get currentUser => _supabase.auth.currentUser;
}
