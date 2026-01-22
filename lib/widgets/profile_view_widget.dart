import 'package:flutter/material.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/game_metadata.dart';

// --- Extension: GameType'a Görsel Özellikler Ekliyoruz ---
extension GameTypeUI on GameType {
  IconData get icon {
    return switch (this) {
      GameType.flag => Icons.flag,
      GameType.capital => Icons.location_city,
      GameType.distance => Icons.straighten,
      GameType.borderline => Icons.border_all,
      GameType.borderpath => Icons.route,
      GameType.findmap => Icons.explore,
    };
  }

  Color get color {
    return switch (this) {
      GameType.flag => Colors.orangeAccent,
      GameType.capital => Colors.purpleAccent,
      GameType.distance => Colors.tealAccent,
      GameType.borderline => Colors.pinkAccent,
      GameType.borderpath => Colors.blueAccent,
      GameType.findmap => Colors.greenAccent,
    };
  }
}

class ProfileViewWidget extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final int totalScore;
  final Map<String, dynamic> stats;

  const ProfileViewWidget({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.totalScore,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 24),
          _buildDetailedStatsCard(isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'profile_avatar',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  _buildTotalScoreBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '${Localization.t('profile.total_score')}: $totalScore',
        style: const TextStyle(
          color: Colors.amberAccent,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildDetailedStatsCard(bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localization.t('profile.stats_title'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.blueGrey.shade900,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            ...GameType.values.map((type) {
              final isLast = type == GameType.values.last;
              final prefix = AppState.getGameModeKey(type);

              return Column(
                children: [
                  _buildSection(prefix, type.icon, type.color, isDark),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Divider(
                        color: isDark ? Colors.white10 : Colors.black12,
                        height: 1,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String prefix, IconData icon, Color color, bool isDark) {
    // Veri güvenliği için toInt benzeri bir yaklaşım
    final int score = (stats['score_$prefix'] ?? 0).toInt();
    final int correct = (stats['${prefix}_correct'] ?? 0).toInt();
    final int wrong = (stats['${prefix}_wrong'] ?? 0).toInt();
    final int total = correct + wrong;
    final double successRate = total > 0 ? (correct / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  Localization.t('profile.$prefix'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              score.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: successRate,
            backgroundColor: isDark ? Colors.black26 : Colors.grey.shade100,
            color: color,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSmallStat(
                Localization.t('profile.correct_label', args: [correct]),
                Colors.green.shade400),
            _buildSmallStat(
                Localization.t('profile.wrong_label', args: [wrong]),
                Colors.red.shade400),
            _buildSmallStat("${(successRate * 100).toStringAsFixed(1)}%",
                isDark ? Colors.white54 : Colors.blueGrey),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStat(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
