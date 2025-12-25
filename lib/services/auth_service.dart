import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_context.dart';
import '../util.dart'; // Global değişkenlerin olduğu yer
import 'storage_service.dart'; // StorageService

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
        return null; // Hata yok, başarılı
      }
      return "Giriş yapılamadı.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Bilinmeyen hata: $e";
    }
  }

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Supabase çıkış hatası: $e");
    }
    await _resetLocalData();
  }

  static bool get isAuthenticated => _supabase.auth.currentUser != null;

  static String? get currentUserId => _supabase.auth.currentUser?.id;

  static Future<void> checkSession() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      await _resetLocalData();
    } else {
      // Oturum varsa verileri tazele
      await syncUserData(session.user);
    }
  }

  /// 🔹 Supabase <-> Local Senkronizasyonu (Core Logic)
  static Future<void> syncUserData(User authUser) async {
    try {
      final profileData = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('uid', authUser.id)
          .maybeSingle();

      if (profileData != null) {
        // ✅ VARSA: Verileri yerel değişkenlere ata
        AppState.user.name = profileData['full_name'] ?? 'Oyuncu';
        AppState.user.avatarUrl = profileData['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';

        AppState.user = UserProfile(name: AppState.user.name, avatarUrl: AppState.user.avatarUrl);
      } else {
        final newName = authUser.userMetadata?['full_name'] ?? 'Oyuncu';
        final newUrl = authUser.userMetadata?['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';

        AppState.user = UserProfile(name: newName, avatarUrl: newUrl);

        await _createUserProfile(authUser, newName, newUrl);
      }

      // 3. İstatistikleri Çek
      final statsData = await _supabase
          .from('geogame_stats')
          .select()
          .eq('user_id', authUser.id)
          .maybeSingle();

      if (statsData != null) {
        mesafepuan = (statsData['mesafepuan'] ?? 0) as int;
        bayrakpuan = (statsData['bayrakpuan'] ?? 0) as int;
        baskentpuan = (statsData['baskentpuan'] ?? 0) as int;
        toplampuan = (statsData['puan'] ?? 0) as int;

        mesafedogru = (statsData['mesafedogru'] ?? 0) as int;
        mesafeyanlis = (statsData['mesafeyanlis'] ?? 0) as int;
        bayrakdogru = (statsData['bayrakdogru'] ?? 0) as int;
        bayrakyanlis = (statsData['bayrakyanlis'] ?? 0) as int;
        baskentdogru = (statsData['baskentdogru'] ?? 0) as int;
        baskentyanlis = (statsData['baskentyanlis'] ?? 0) as int;
      } else {
        await _createUserStats(authUser.id);
        _resetStatsVariables(); // İstatistikleri sıfırla
      }

      // 4. Kalıcı Hafızaya Yaz
      await StorageService.saveLocalData();
      debugPrint('✅ Veriler senkronize edildi: $AppState.user.name');

    } catch (e) {
      debugPrint('❌ Sync Hatası: $e');
      throw e; // Hatayı yukarı fırlat ki UI bilsin
    }
  }

  // --- Private Helper Methods ---

  static Future<void> _createUserProfile(User authUser, String initialName, String initialUrl) async {
    await _supabase.from('profiles').upsert({
      'uid': authUser.id,
      'email': authUser.email,
      'full_name': initialName,
      'avatar_url': initialUrl,
    }, onConflict: 'uid');
  }

  static Future<void> _createUserStats(String userId) async {
    await _supabase.from('geogame_stats').upsert({
      'user_id': userId,
      'puan': 0,
      'mesafepuan': 0,
      'bayrakpuan': 0,
      'baskentpuan': 0,
      'mesafedogru': 0,
      'mesafeyanlis': 0,
      'bayrakdogru': 0,
      'bayrakyanlis': 0,
      'baskentdogru': 0,
      'baskentyanlis': 0,
    }, onConflict: 'user_id');
  }

  static Future<void> _resetLocalData() async {
    AppState.user = UserProfile(name: "", avatarUrl: 'https://geogame-cdn.keremkk.com.tr/anon.png');

    _resetStatsVariables();
    await StorageService.saveLocalData();
  }

  static void _resetStatsVariables() {
    mesafedogru = 0; mesafeyanlis = 0;
    bayrakdogru = 0; bayrakyanlis = 0;
    baskentdogru = 0; baskentyanlis = 0;
    mesafepuan = 0; bayrakpuan = 0; baskentpuan = 0;
    toplampuan = 0;
  }
}