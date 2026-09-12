import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/localization_service.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

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

  static Future<void> syncUserData(User authUser) async {
    try {
      // 1. Önce profiles tablosuna bak
      final profileData = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('uid', authUser.id)
          .maybeSingle();

      String name;
      String avatar;

      // 2. Profil zaten varsa SADECE profiles kullan
      if (profileData != null) {
        name = profileData['full_name']?.toString().trim() ?? '';
        avatar = profileData['avatar_url']?.toString().trim() ?? '';

        if (name.isEmpty) {
          name = Localization.t('settings.guest');
        }

        if (avatar.isEmpty) {
          avatar = 'https://robohash.org/${authUser.id}';
        }
      }

      // 3. Profil yoksa Supabase user metadata'dan oluştur
      else {
        final metadata = authUser.userMetadata ?? {};

        name = metadata['full_name']?.toString().trim() ??
            metadata['name']?.toString().trim() ??
            authUser.email?.split('@').first ??
            Localization.t('settings.guest');

        avatar = metadata['avatar_url']?.toString().trim() ??
            metadata['picture']?.toString().trim() ??
            'https://robohash.org/${authUser.id}';

        // 4. İlk giriş → profiles'a kaydet
        await _supabase.from('profiles').insert({
          'uid': authUser.id,
          'full_name': name,
          'avatar_url': avatar,
        });
      }

      // 5. Uygulamadaki kullanıcıyı güncelle
      AppState.user = UserProfile(
        name: name,
        avatarUrl: avatar,
      );

      debugPrint(
        '✅ User synced: $name, Avatar: $avatar',
      );
    } catch (e) {
      debugPrint('❌ Profile sync error: $e');
    }
  }

  /// Global Supabase Auth durum dinleyicisi
  static void initAuthStateListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      debugPrint('🔔 Supabase Auth State Changed: $event');
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.userUpdated ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.initialSession) {
        if (session?.user != null) {
          await syncUserData(session!.user);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        AppState.user = UserProfile.anonymous();
      }
    });
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
}
