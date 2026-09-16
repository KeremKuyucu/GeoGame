/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/game_log_service.dart';

/// Başarım model sınıfı
class AchievementItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;

  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
  });

  factory AchievementItem.fromMap(Map<String, dynamic> map) {
    return AchievementItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      icon: map['icon']?.toString() ?? '🏆',
      points: (map['points'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Supabase check_achievements RPC'sini yöneten ve
/// yeni kazanılan başarımları görsel olarak bildiren servis.
class AchievementService {
  static final _supabase = Supabase.instance.client;
  static bool _isChecking = false;

  /// Supabase check_achievements RPC'sini çağırır.
  /// Yeni açılan başarımlar varsa bildirimlerini gösterir.
  static Future<List<AchievementItem>> checkAchievements() async {
    if (!AuthService.isAuthenticated) return [];
    if (_isChecking) return [];

    _isChecking = true;

    try {
      // 1. Bekleyen soru loglarını Supabase'e aktar
      await GameLogService.syncPendingLogs();

      // 2. RPC çağrısı
      final response = await _supabase.rpc('check_achievements');
      if (response == null || response is! List || response.isEmpty) {
        return [];
      }

      final List<String> newUnlockedIds = [];
      for (final row in response) {
        if (row is Map && (row['unlocked'] == true || row['unlocked'] == 1)) {
          final id = row['achievement_id']?.toString();
          if (id != null && id.isNotEmpty) {
            newUnlockedIds.add(id);
          }
        }
      }

      if (newUnlockedIds.isEmpty) return [];

      debugPrint('🏆 Yeni kazanılan başarımlar: $newUnlockedIds');

      // 3. Başarım detaylarını çöz (önce yerel katalog, eksik kalırsa Supabase)
      final achievements = await _resolveAchievements(newUnlockedIds);

      // 4. Yeni açılan her başarım için görsel bildirim göster
      for (final item in achievements) {
        showAchievementNotification(item);
      }

      return achievements;
    } catch (e) {
      debugPrint('❌ Achievement check error: $e');
      return [];
    } finally {
      _isChecking = false;
    }
  }

  /// Başarım kimliklerinden detay bilgilerini oluşturur
  static Future<List<AchievementItem>> _resolveAchievements(
      List<String> ids) async {
    final List<AchievementItem> result = [];
    final List<String> missingIds = [];

    for (final id in ids) {
      if (defaultAchievements.containsKey(id)) {
        result.add(defaultAchievements[id]!);
      } else {
        missingIds.add(id);
      }
    }

    if (missingIds.isNotEmpty) {
      try {
        final data = await _supabase
            .from('achievements')
            .select('id, title, description, icon, points')
            .inFilter('id', missingIds);

        for (final row in data) {
          result.add(AchievementItem.fromMap(row));
        }
      } catch (e) {
        debugPrint('⚠️ Eksik başarımlar çekilemedi: $e');
      }
    }

    return result;
  }

  /// Yeni kazanılan başarım için özel şık bildirim (SnackBar) gösterir
  static void showAchievementNotification(AchievementItem achievement) {
    final messenger = AppState.scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    messenger.showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Rozet / Emoji İkonu
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),

              // Başlık ve Açıklama
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🏆 BAŞARIM AÇILDI!',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const Spacer(),
                        if (achievement.points > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.amber.withOpacity(0.5),
                                  width: 0.8),
                            ),
                            child: Text(
                              '+${achievement.points} Puan',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      achievement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1E222D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.amber.withOpacity(0.6),
            width: 1.2,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  /// Standart başarım kataloğu (hızlı yerel erişim ve fallback için)
  static final Map<String, AchievementItem> defaultAchievements = {
    'africa_explorer': const AchievementItem(
      id: 'africa_explorer',
      title: 'Afrika Kaşifi',
      description: 'Afrika kıtasından 30 ülke bil.',
      icon: '🦁',
      points: 30,
    ),
    'all_rounder': const AchievementItem(
      id: 'all_rounder',
      title: 'Çok Yönlü',
      description: 'Her oyun modunda en az bir oyun tamamla.',
      icon: '🎮',
      points: 50,
    ),
    'asia_explorer': const AchievementItem(
      id: 'asia_explorer',
      title: 'Asya Seyyahı',
      description: 'Asya kıtasından 30 ülke bil.',
      icon: '🏯',
      points: 30,
    ),
    'border_optimal': const AchievementItem(
      id: 'border_optimal',
      title: 'Kestirme Yolu',
      description: 'Sınır Yolu oyununu optimal (en kısa) rotayla tamamla.',
      icon: '🧭',
      points: 30,
    ),
    'borderpath_25': const AchievementItem(
      id: 'borderpath_25',
      title: 'Sınır Uzmanı',
      description: '25 Sınır Yolu rotasını tamamla.',
      icon: '🗺️',
      points: 75,
    ),
    'borderpath_5': const AchievementItem(
      id: 'borderpath_5',
      title: 'Sınır Komşusu',
      description: '5 Sınır Yolu rotasını tamamla.',
      icon: '🧭',
      points: 20,
    ),
    'borderpath_50': const AchievementItem(
      id: 'borderpath_50',
      title: 'Sınır Ağı',
      description: '50 Sınır Yolu rotasını tamamla.',
      icon: '🌐',
      points: 125,
    ),
    'borderpath_optimal_10': const AchievementItem(
      id: 'borderpath_optimal_10',
      title: 'Harita Mühendisi',
      description: '10 optimal Sınır Yolu rotası tamamla.',
      icon: '📐',
      points: 150,
    ),
    'borderpath_optimal_5': const AchievementItem(
      id: 'borderpath_optimal_5',
      title: 'Kısa Yol Ustası',
      description: '5 optimal Sınır Yolu rotası tamamla.',
      icon: '🧭',
      points: 75,
    ),
    'capital_10': const AchievementItem(
      id: 'capital_10',
      title: 'Başkent Çırağı',
      description: 'Başkent oyununda 10 doğru cevap ver.',
      icon: '🏛️',
      points: 20,
    ),
    'capital_100': const AchievementItem(
      id: 'capital_100',
      title: 'Başkent Ustası',
      description: 'Başkent oyununda 100 doğru cevap ver.',
      icon: '👑',
      points: 120,
    ),
    'capital_50': const AchievementItem(
      id: 'capital_50',
      title: 'Başkent Uzmanı',
      description: 'Başkent oyununda 50 doğru cevap ver.',
      icon: '🏛️',
      points: 60,
    ),
    'capital_perfect': const AchievementItem(
      id: 'capital_perfect',
      title: 'Başkent Dehası',
      description: 'Bir Başkent oyununu hiç yanlış yapmadan tamamla.',
      icon: '🧠',
      points: 75,
    ),
    'century_club': const AchievementItem(
      id: 'century_club',
      title: '100 Kulübü',
      description: 'Toplam 100 soruya doğru cevap ver.',
      icon: '💯',
      points: 40,
    ),
    'daily_30': const AchievementItem(
      id: 'daily_30',
      title: 'Sadık Oyuncu',
      description: '30 farklı günde oyun oyna.',
      icon: '🗓️',
      points: 100,
    ),
    'daily_7': const AchievementItem(
      id: 'daily_7',
      title: 'Düzenli Oyuncu',
      description: '7 farklı günde oyun oyna.',
      icon: '📅',
      points: 50,
    ),
    'distance_10': const AchievementItem(
      id: 'distance_10',
      title: 'Yolun Başında',
      description: 'Mesafe Avı oyununda 10 doğru tahmin yap.',
      icon: '🛣️',
      points: 20,
    ),
    'distance_50': const AchievementItem(
      id: 'distance_50',
      title: 'Mesafe Uzmanı',
      description: 'Mesafe Avı oyununda 50 doğru tahmin yap.',
      icon: '📏',
      points: 60,
    ),
    'distance_sniper': const AchievementItem(
      id: 'distance_sniper',
      title: 'Keskin Nişancı',
      description: 'Mesafe Avı oyununu ilk tahmininde bil.',
      icon: '🎯',
      points: 50,
    ),
    'distance_sniper_10': const AchievementItem(
      id: 'distance_sniper_10',
      title: 'Ölçüm Ustası',
      description: 'Mesafe Avı oyununda 10 kez ilk tahminde bil.',
      icon: '🎯',
      points: 125,
    ),
    'distance_sniper_5': const AchievementItem(
      id: 'distance_sniper_5',
      title: 'Çifte Keskinlik',
      description: 'Mesafe Avı oyununda 5 kez ilk tahminde bil.',
      icon: '🎯',
      points: 75,
    ),
    'europe_explorer': const AchievementItem(
      id: 'europe_explorer',
      title: 'Avrupa Fatihi',
      description: 'Avrupa kıtasından 30 ülke bil.',
      icon: '🏰',
      points: 30,
    ),
    'first_correct': const AchievementItem(
      id: 'first_correct',
      title: 'İlk Adım',
      description: 'Herhangi bir oyunda ilk doğru cevabını ver.',
      icon: '🚀',
      points: 10,
    ),
    'flag_10': const AchievementItem(
      id: 'flag_10',
      title: 'Bayrak Avcısı',
      description: 'Bayrak oyununda 10 doğru cevap ver.',
      icon: '🚩',
      points: 20,
    ),
    'flag_100': const AchievementItem(
      id: 'flag_100',
      title: 'Bayrak Ustası',
      description: 'Bayrak oyununda 100 doğru cevap ver.',
      icon: '🎌',
      points: 120,
    ),
    'flag_50': const AchievementItem(
      id: 'flag_50',
      title: 'Bayrak Uzmanı',
      description: 'Bayrak oyununda 50 doğru cevap ver.',
      icon: '🏳️',
      points: 60,
    ),
    'flag_perfect': const AchievementItem(
      id: 'flag_perfect',
      title: 'Bayrak Koleksiyoncusu',
      description: 'Bir Bayrak oyununu hiç yanlış yapmadan tamamla.',
      icon: '🏆',
      points: 75,
    ),
    'master_geographer': const AchievementItem(
      id: 'master_geographer',
      title: 'Coğrafya Profesörü',
      description: 'Toplam 1.000 puan topla.',
      icon: '👑',
      points: 100,
    ),
    'night_owl': const AchievementItem(
      id: 'night_owl',
      title: 'Gece Kuşu',
      description: 'Gece geç saatlerde bir oyun tamamla.',
      icon: '🌙',
      points: 50,
    ),
    'perfect_game': const AchievementItem(
      id: 'perfect_game',
      title: 'Hatasız',
      description: 'Bir oyunu hiç yanlış cevap vermeden tamamla.',
      icon: '✨',
      points: 50,
    ),
    'questions_1000': const AchievementItem(
      id: 'questions_1000',
      title: 'Coğrafya Ustası',
      description: 'Toplam 1.000 soruya doğru cevap ver.',
      icon: '🌍',
      points: 150,
    ),
    'questions_250': const AchievementItem(
      id: 'questions_250',
      title: 'Çeyrek Bin',
      description: 'Toplam 250 soruya doğru cevap ver.',
      icon: '📚',
      points: 50,
    ),
    'questions_2500': const AchievementItem(
      id: 'questions_2500',
      title: 'Dünya Bilgini',
      description: 'Toplam 2.500 soruya doğru cevap ver.',
      icon: '🎓',
      points: 250,
    ),
    'questions_500': const AchievementItem(
      id: 'questions_500',
      title: 'Bilgi Hazinesi',
      description: 'Toplam 500 soruya doğru cevap ver.',
      icon: '🧠',
      points: 75,
    ),
    'streak_10': const AchievementItem(
      id: 'streak_10',
      title: 'Durdurulamaz',
      description: 'Üst üste 10 doğru cevap ver.',
      icon: '⚡',
      points: 50,
    ),
    'streak_15': const AchievementItem(
      id: 'streak_15',
      title: 'Alev Alev',
      description: 'Üst üste 15 doğru cevap ver.',
      icon: '🔥',
      points: 75,
    ),
    'streak_20': const AchievementItem(
      id: 'streak_20',
      title: 'Zinciri Kırma',
      description: 'Üst üste 20 doğru cevap ver.',
      icon: '⚡',
      points: 100,
    ),
    'streak_30': const AchievementItem(
      id: 'streak_30',
      title: 'Efsane Seri',
      description: 'Üst üste 30 doğru cevap ver.',
      icon: '💥',
      points: 200,
    ),
    'streak_5': const AchievementItem(
      id: 'streak_5',
      title: 'Ateş Aldın!',
      description: 'Üst üste 5 doğru cevap ver.',
      icon: '🔥',
      points: 20,
    ),
    'world_traveler': const AchievementItem(
      id: 'world_traveler',
      title: 'Dünyayı Turladım',
      description: 'Dünyadaki tüm ülkeleri en az bir kez doğru bil.',
      icon: '🌎',
      points: 500,
    ),
  };
}
*/