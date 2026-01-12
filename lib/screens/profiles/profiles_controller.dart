import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';

/// Profiles için veri ve iş mantığı controller'ı
class ProfilesController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? userStats;
  bool isLoading = true;
  String? errorMessage;

  /// Kullanıcı giriş yapmış mı?
  bool get isAuthenticated => AuthService.isAuthenticated;

  /// Kullanıcı adı
  String get userName {
    return AppState.user.name.isNotEmpty
        ? AppState.user.name
        : Localization.t('settings.guest');
  }

  /// Kullanıcı avatar URL'si
  String get userAvatar => AppState.user.avatarUrl;

  /// Toplam skor
  int get totalScore {
    if (userStats == null) return 0;
    return userStats!['total_score'] ?? 0;
  }

  /// Stats verisini döndürür (null ise boş map)
  Map<String, dynamic> get statsData => userStats ?? {};

  /// Kullanıcı profil verilerini Supabase'den çeker
  Future<void> fetchUserProfile() async {
    final String? currentId = AuthService.currentUserId;

    if (currentId == null) {
      isLoading = false;
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      final data = await _supabase
          .from('leaderboard_view')
          .select()
          .eq('uid', currentId)
          .maybeSingle();

      userStats = data;
      isLoading = false;
    } catch (e) {
      debugPrint('❌ Profil yükleme hatası: $e');
      errorMessage = 'Hata: $e';
      isLoading = false;
    }
  }

  /// Auth sayfasına yönlendirir
  void navigateToAuth(BuildContext context) {
    Navigator.pushNamed(context, '/auth');
  }
}
