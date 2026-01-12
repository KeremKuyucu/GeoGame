import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/profile_view_widget.dart';

/// Leaderboard için veri ve iş mantığı controller'ı
class LeaderboardController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? errorMessage;

  /// Leaderboard verisini Supabase'den çeker
  Future<void> fetchLeaderboard() async {
    isLoading = true;
    errorMessage = null;

    try {
      final response =
          await _supabase.from('leaderboard_view').select().limit(100);

      if ((response as List).isEmpty) {
        users = [];
        isLoading = false;
        return;
      }

      users = _parseLeaderboardData(response);
      isLoading = false;
    } catch (e) {
      debugPrint('❌ Leaderboard Error: $e');
      errorMessage = Localization.t('leaderboard.load_error');
      isLoading = false;
    }
  }

  /// Ham veriyi parse eder
  List<Map<String, dynamic>> _parseLeaderboardData(List<dynamic> rawList) {
    return rawList.map((row) {
      final Map<String, dynamic> userMap = {
        'rank': _toInt(row['rank']),
        'uid': row['uid']?.toString() ?? '',
        'name':
            row['full_name']?.toString() ?? Localization.t('settings.guest'),
        'avatar_url': row['avatar_url']?.toString() ??
            'https://robohash.org/kaplan.png?set=set4',
        'total_score': _toInt(row['total_score']),
        'total_correct': _toInt(row['total_correct']),
        'total_wrong': _toInt(row['total_wrong']),
      };

      for (var type in GameType.values) {
        final String mode = AppState.getGameModeKey(type);
        userMap['score_$mode'] = _toInt(row['score_$mode']);
        userMap['${mode}_correct'] = _toInt(row['${mode}_correct']);
        userMap['${mode}_wrong'] = _toInt(row['${mode}_wrong']);
      }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(user['name'] ?? ''),
            centerTitle: true,
          ),
          body: ProfileViewWidget(
            name: user['name'] ?? Localization.t('settings.guest'),
            avatarUrl: user['avatar_url'] ??
                'https://robohash.org/kaplan.png?set=set4',
            totalScore: user['total_score'] ?? 0,
            stats: user,
          ),
        ),
      ),
    );
  }
}
