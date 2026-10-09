import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/auth_service.dart';

/// Profiles için veri ve iş mantığı controller'ı
class ProfilesController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? userStats;
  bool isLoading = true;
  bool isOffline = false;
  String? errorMessage;

  /// Kullanıcı giriş yapmış mı?
  bool get isAuthenticated => AuthService.isAuthenticated;

  /// Kullanıcı adı
  String get userName => AppState.user.name;

  /// Kullanıcı avatar URL'si
  String get userAvatar => AppState.user.avatarUrl;

  /// Toplam skor
  int get totalScore {
    if (userStats == null) return 0;
    return (userStats!['total_score'] as num?)?.toInt() ?? 0;
  }

  /// Toplam doğru cevap
  int get totalCorrect {
    if (userStats == null) return 0;
    return (userStats!['total_correct'] as num?)?.toInt() ?? 0;
  }

  /// Toplam yanlış cevap
  int get totalWrong {
    if (userStats == null) return 0;
    return (userStats!['total_wrong'] as num?)?.toInt() ?? 0;
  }

  /// Toplam soru sayısı
  int get totalQuestions => totalCorrect + totalWrong;

  /// Genel başarı oranı (%)
  double get overallAccuracy =>
      totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;

  /// Ülke bazlı istatistikler
  Map<String, dynamic> get countryStats {
    if (userStats == null) return {};
    final raw = userStats!['country_stats'];
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  /// Stats verisini döndürür (null ise boş map)
  Map<String, dynamic> get statsData => userStats ?? {};

  /// Kullanıcı profil verilerini Supabase'den çeker
  Future<void> fetchUserProfile() async {
    final String? currentId = AuthService.currentUserId;

    isLoading = true;
    errorMessage = null;
    isOffline = false;

    if (currentId == null) {
      isLoading = false;
      return;
    }

    try {
      // leaderboard_v2 yerine doğrudan kullanıcıya özel view
      final data = await _supabase
          .from('user_profile_detail')
          .select()
          .eq('uid', currentId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      if (data != null) {
        userStats = _parseProfileData(data);
      } else {
        userStats = null;
      }
      isLoading = false;
    } catch (e) {
      debugPrint('❌ Profil yükleme hatası: $e');
      isOffline = true;
      errorMessage = 'Hata: $e';
      isLoading = false;
    }
  }

  Map<String, dynamic> _parseProfileData(Map<String, dynamic> rawData) {
    final Map<String, dynamic> result = Map.from(rawData);

    // 1. Modes verisini çözümle (Map ya da String JSON)
    Map<String, dynamic> modesData = {};
    final rawModes = rawData['modes'];
    if (rawModes is Map) {
      modesData = Map<String, dynamic>.from(rawModes);
    } else if (rawModes is String && rawModes.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawModes);
        if (decoded is Map) {
          modesData = Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        debugPrint('⚠️ Modes jsonDecode hatası: $e');
      }
    }

    // 2. Country Stats verisini çözümle (Map ya da String JSON)
    Map<String, dynamic> countryStatsData = {};
    final rawCountryStats = rawData['country_stats'];
    if (rawCountryStats is Map) {
      countryStatsData = Map<String, dynamic>.from(rawCountryStats);
    } else if (rawCountryStats is String && rawCountryStats.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawCountryStats);
        if (decoded is Map) {
          countryStatsData = Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        debugPrint('⚠️ Country stats jsonDecode hatası: $e');
      }
    }

    result['modes'] = modesData;
    result['country_stats'] = countryStatsData;

    for (var type in GameType.values) {
      final String mode = AppState.getGameModeKey(type);
      final dynamic rawModeStat = modesData[mode];
      final modeStat = rawModeStat is Map ? Map<String, dynamic>.from(rawModeStat) : {};

      result['score_$mode'] = modeStat['score'] ?? 0;
      result['${mode}_correct'] = modeStat['correct'] ?? 0;
      result['${mode}_wrong'] = modeStat['wrong'] ?? 0;
    }
    return result;
  }

  /// Auth sayfasına yönlendirir
  void navigateToAuth(BuildContext context) {
    Navigator.pushNamed(context, '/auth');
  }
}
