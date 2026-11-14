import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/profile_view_widget.dart';

/// Leaderboard için veri ve iş mantığı controller'ı
class LeaderboardController {
  final SupabaseClient _supabase = Supabase.instance.client;

  static List<Map<String, dynamic>>? _cachedUsers;

  List<Map<String, dynamic>> users =
      _cachedUsers != null ? List.from(_cachedUsers!) : [];
  bool isLoading = _cachedUsers == null;
  bool isOffline = false;
  String? errorMessage;

  /// Leaderboard verisini Supabase'den çeker
  Future<void> fetchLeaderboard() async {
    if (users.isEmpty) {
      isLoading = true;
    }
    errorMessage = null;
    isOffline = false;

    try {
      final response = await _supabase
          .from('leaderboard_v2')
          .select()
          .limit(100)
          .timeout(const Duration(seconds: 10));

      if ((response as List).isEmpty) {
        users = [];
        _cachedUsers = [];
        isLoading = false;
        return;
      }

      users = _parseLeaderboardData(response);
      _cachedUsers = users;
      isLoading = false;
    } catch (e) {
      debugPrint('❌ Leaderboard Error: $e');
      isOffline = true;
      errorMessage = Localization.t('leaderboard.load_error');
      isLoading = false;
    }
  }

  /// Ham veriyi parse eder
  List<Map<String, dynamic>> _parseLeaderboardData(List<dynamic> rawList) {
    return rawList.map((row) {
      final Map<String, dynamic> modesData = row['modes'] ?? {};

      final Map<String, dynamic> userMap = {
        'rank': _toInt(row['rank']),
        'uid': row['uid']?.toString() ?? '',
        'name': (row['full_name'] != null && row['full_name'].toString().trim().isNotEmpty)
            ? row['full_name'].toString()
            : Localization.t('player'),
        'avatar_url': row['avatar_url']?.toString() ?? '',
        'total_score': _toInt(row['total_score']),
      };

      int calcTotalCorrect = 0;
      int calcTotalWrong = 0;

      for (var type in GameType.values) {
        final String mode = AppState.getGameModeKey(type);
        final modeStat = modesData[mode] ?? {};

        final score = _toInt(modeStat['score']);
        final correct = _toInt(modeStat['correct']);
        final wrong = _toInt(modeStat['wrong']);

        userMap['score_$mode'] = score;
        userMap['${mode}_correct'] = correct;
        userMap['${mode}_wrong'] = wrong;

        calcTotalCorrect += correct;
        calcTotalWrong += wrong;
      }

      userMap['total_correct'] = calcTotalCorrect;
      userMap['total_wrong'] = calcTotalWrong;

      return userMap;
    }).toList();
  }

  int _toInt(dynamic value) {
    return (value is num)
        ? value.toInt()
        : (int.tryParse(value?.toString() ?? '0') ?? 0);
  }

  /// Sıralamaya göre renk döndürür
  Color getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return Colors.blueAccent.withValues(alpha: 0.1);
    }
  }

  /// Sıralama podyum gradient renkleri
  List<Color> getRankGradient(int index) {
    switch (index) {
      case 0:
        return const [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFF8F00)];
      case 1:
        return const [Color(0xFFFFFFFF), Color(0xFFCFD8DC), Color(0xFF90A4AE)];
      case 2:
        return const [Color(0xFFFFD180), Color(0xFFD78C53), Color(0xFFA1887F)];
      default:
        return const [Color(0xFF8C52FF), Color(0xFF5CE1E6)];
    }
  }

  /// Sıralama podyum ışıltı rengi
  Color getRankGlowColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFB300).withValues(alpha: 0.5);
      case 1:
        return const Color(0xFFB0BEC5).withValues(alpha: 0.4);
      case 2:
        return const Color(0xFFCD7F32).withValues(alpha: 0.4);
      default:
        return Colors.transparent;
    }
  }

  /// Tema durumuna göre arka plan renklerini döndürür (MainScreen ile birebir uyumlu)
  List<Color> getBackgroundColors(bool isDark) {
    return isDark
        ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
        : [const Color(0xFFF5F7FA), const Color(0xFFC3CFE2)];
  }

  /// Giriş yapmış kullanıcının UID'si
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Belirtilen kullanıcının oturum açmış kullanıcı olup olmadığını kontrol eder
  bool isCurrentUser(Map<String, dynamic> user) {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return false;
    return user['uid'] == uid;
  }

  /// Oturum açmış kullanıcının sıralamadaki sırası (1 tabanlı)
  int? get currentUserRank {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return null;
    for (int i = 0; i < users.length; i++) {
      if (users[i]['uid'] == uid) return i + 1;
    }
    return null;
  }

  /// Oturum açmış kullanıcının leaderboard verisi
  Map<String, dynamic>? get currentUserEntry {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return null;
    for (final u in users) {
      if (u['uid'] == uid) return u;
    }
    return null;
  }

  /// Sıralama yazı rengi
  Color getRankTextColor(int index) {
    if (index < 3) return Colors.white;
    return Colors.blueAccent;
  }

  /// Podium için üst 3 kullanıcı var mı?
  bool get hasPodium => users.length >= 3;

  /// Liste için kullanıcı sayısı (podium hariç)
  int get listUserCount => hasPodium ? users.length - 3 : users.length;

  /// Liste indeksini gerçek indekse çevirir
  int getActualIndex(int listIndex) => hasPodium ? listIndex + 3 : listIndex;

  /// Profil sayfasına yönlendirir
  void navigateToProfile(BuildContext context, Map<String, dynamic> user) {
    final String name = (user['name']?.toString().trim().isNotEmpty ?? false)
        ? user['name'].toString()
        : Localization.t('player');
    final String avatarUrl = user['avatar_url']?.toString() ?? '';
    final int totalScore = _toInt(user['total_score']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF2C2C3E),
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: getBackgroundColors(isDark),
                ),
              ),
              child: ProfileViewWidget(
                name: name,
                avatarUrl: avatarUrl,
                totalScore: totalScore,
                stats: user,
                isOwnProfile: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
