import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/models/app_context.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔐 Giriş Yap
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
      return "Giriş yapılamadı.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Bilinmeyen hata: $e";
    }
  }

  /// 📝 Kayıt Ol (YENİ EKLENDİ)
  static Future<String?> signUp(String email, String password, String name) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'avatar_url': 'https://geogame-cdn.keremkk.com.tr/anon.png',
        },
      );

      if (res.user != null) {
        await syncUserData(res.user!);
        return null;
      }

      return "The registration process failed.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unknown error: $e";
    }
  }

  /// 🚪 Çıkış Yap
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Supabase exit error: $e");
    }
    AppState.user = UserProfile.anonymous();
  }

  // Helper Getter'lar
  static bool get isAuthenticated => _supabase.auth.currentUser != null;
  static String? get currentUserId => _supabase.auth.currentUser?.id;

  /// 🔄 Uygulama Açılışında Oturum Kontrolü
  static Future<void> checkSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await syncUserData(session.user);
    }
  }

  /// 👤 Profil Bilgilerini Çek ve RAM'e (AppState) Yaz
  static Future<void> syncUserData(User authUser) async {
    try {
      // Önce veritabanında profil var mı diye bak
      final profileData = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('uid', authUser.id)
          .maybeSingle();

      if (profileData != null) {
        // Varsa onu yükle
        AppState.user = UserProfile(
            name: profileData['full_name'] ?? 'Oyuncu',
            avatarUrl: profileData['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png'
        );
      } else {
        final newName = authUser.userMetadata?['full_name'] ?? 'Oyuncu';
        final newUrl = authUser.userMetadata?['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';

        // RAM'i güncelle
        AppState.user = UserProfile(name: newName, avatarUrl: newUrl);

        // Veritabanında profili oluştur
        await _createUserProfile(authUser, newName, newUrl);
      }

      debugPrint('✅ Profile data loaded: ${AppState.user.name}');

    } catch (e) {
      debugPrint('❌ Profile Upload Error: $e');
    }
  }

  static Future<void> _createUserProfile(User authUser, String initialName, String initialUrl) async {
    try {
      await _supabase.from('profiles').upsert({
        'uid': authUser.id,
        'email': authUser.email,
        'full_name': initialName,
        'avatar_url': initialUrl,
      }, onConflict: 'uid');
    } catch (e) {
      debugPrint("Profile DB creation error: $e");
    }
  }
  static Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return null; // Başarılı
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}