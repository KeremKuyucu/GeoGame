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
        emailRedirectTo: redirectUrl,
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
      // Web ve Masaüstü (Windows vb.) platformlarda doğrudan OAuth akışını kullan
      if (kIsWeb ||
          (defaultTargetPlatform != TargetPlatform.android &&
              defaultTargetPlatform != TargetPlatform.iOS)) {
        return await _signInWithOAuthFallback();
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            Env.googleWebClientId.isNotEmpty ? Env.googleWebClientId : null,
        clientId:
            Env.googleIosClientId.isNotEmpty ? Env.googleIosClientId : null,
        scopes: const ['email', 'profile'],
      );

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
        await syncUserData(
          res.user!,
          googleName: googleUser.displayName,
          googleAvatar: googleUser.photoUrl,
        );
        return null;
      }
      return Localization.t('auth.error_login_failed');
    } on AuthException catch (e) {
      debugPrint('AuthException in Google Sign-In: ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Unexpected error in Google Sign-In: $e');
      return await _signInWithOAuthFallback();
    }
  }

  static String get redirectUrl => kIsWeb
      ? '${Uri.base.origin}/'
      : 'io.supabase.geogame://login-callback/';

  /// Supabase OAuth tarayıcı tabanlı yönlendirme alternatifi
  static Future<String?> _signInWithOAuthFallback() async {
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
      return e.message;
    } catch (e) {
      return Localization.t('auth.error_google_sign_in');
    }
  }

  static Future<void> syncUserData(
    User authUser, {
    String? googleName,
    String? googleAvatar,
  }) async {
    try {
      final rawMeta = authUser.userMetadata ?? {};

      // 1. ANINDA yerel oturum bilgilerini ayarla (Bekleme yapmadan!)
      String candidateName = '';
      if (googleName != null && googleName.trim().isNotEmpty) {
        candidateName = googleName.trim();
      } else if (rawMeta['full_name'] != null &&
          rawMeta['full_name'].toString().trim().isNotEmpty) {
        candidateName = rawMeta['full_name'].toString().trim();
      } else if (rawMeta['name'] != null &&
          rawMeta['name'].toString().trim().isNotEmpty) {
        candidateName = rawMeta['name'].toString().trim();
      } else if (rawMeta['user_name'] != null &&
          rawMeta['user_name'].toString().trim().isNotEmpty) {
        candidateName = rawMeta['user_name'].toString().trim();
      } else {
        candidateName = authUser.email?.split('@').first ??
            Localization.t('settings.guest');
      }

      String candidateAvatar = '';
      if (googleAvatar != null && googleAvatar.trim().isNotEmpty) {
        candidateAvatar = googleAvatar.trim();
      } else if (rawMeta['avatar_url'] != null &&
          rawMeta['avatar_url'].toString().trim().isNotEmpty &&
          !rawMeta['avatar_url'].toString().contains('robohash.org')) {
        candidateAvatar = rawMeta['avatar_url'].toString().trim();
      } else if (rawMeta['picture'] != null &&
          rawMeta['picture'].toString().trim().isNotEmpty &&
          !rawMeta['picture'].toString().contains('robohash.org')) {
        candidateAvatar = rawMeta['picture'].toString().trim();
      } else if (rawMeta['avatar'] != null &&
          rawMeta['avatar'].toString().trim().isNotEmpty &&
          !rawMeta['avatar'].toString().contains('robohash.org')) {
        candidateAvatar = rawMeta['avatar'].toString().trim();
      } else {
        candidateAvatar = 'https://robohash.org/${authUser.id}';
      }

      // AppState.user ANINDA güncellenir
      AppState.user = UserProfile(
        name: candidateName,
        avatarUrl: candidateAvatar,
      );

      // 2. Veritabanından profil kontrolü (Gecikmesiz)
      try {
        final profileData = await _supabase
            .from('profiles')
            .select('full_name, avatar_url')
            .eq('uid', authUser.id)
            .maybeSingle();

        if (profileData != null) {
          final dbName = profileData['full_name']?.toString().trim();
          final dbAvatar = profileData['avatar_url']?.toString().trim();

          if (dbName != null &&
              dbName.isNotEmpty &&
              dbName != Localization.t('settings.guest') &&
              dbName != 'Misafir' &&
              dbName != 'Guest') {
            candidateName = dbName;
          }
          if (dbAvatar != null &&
              dbAvatar.isNotEmpty &&
              !dbAvatar.contains('robohash.org')) {
            candidateAvatar = dbAvatar;
          }

          AppState.user = UserProfile(
            name: candidateName,
            avatarUrl: candidateAvatar,
          );
        }
      } catch (e) {
        debugPrint('Notice: Profile fetch error: $e');
      }

      // 3. Veritabanı (profiles) tablosunu son güncel verilerle doldur
      try {
        await _supabase.from('profiles').upsert({
          'uid': authUser.id,
          'full_name': candidateName,
          'avatar_url': candidateAvatar,
        });
      } catch (e) {
        debugPrint('Notice: Profile upsert error: $e');
      }

      // 4. Supabase userMetadata'yı da senkronize et
      try {
        await _supabase.auth.updateUser(
          UserAttributes(data: {
            'full_name': candidateName,
            'avatar_url': candidateAvatar,
          }),
        );
      } catch (e) {
        debugPrint('Notice: User metadata update: $e');
      }

      debugPrint('✅ Profile sync complete: ${AppState.user.name}, Avatar: ${AppState.user.avatarUrl}');
    } catch (e) {
      debugPrint('❌ Profile Sync Error: $e');
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
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
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
