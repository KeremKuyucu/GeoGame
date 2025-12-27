import 'package:flutter/material.dart';
import 'package:geogame/services/localization_service.dart';

class ProfileViewWidget extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final int totalScore;
  final Map<String, dynamic> stats; // Tüm oyun istatistiklerini içeren Map

  const ProfileViewWidget({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.totalScore,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 20),
          _buildDetailedStatsCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 38,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${Localization.t('profile.total_score')}: $totalScore',
                      style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatsCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              Localization.t('profile.stats_title'),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSection('distance', Icons.map, Colors.tealAccent),
            const Divider(color: Colors.white24, height: 30),
            _buildSection('flag', Icons.flag, Colors.orangeAccent),
            const Divider(color: Colors.white24, height: 30),
            _buildSection('capital', Icons.location_city, Colors.purpleAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String prefix, IconData icon, Color color) {
    int score = stats['${prefix}Score'] ?? 0;
    int correct = stats['${prefix}CorrectCount'] ?? 0;
    int wrong = stats['${prefix}WrongCount'] ?? 0;
    int total = correct + wrong;
    double successRate = total > 0 ? (correct / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(Localization.t('profile.$prefix'), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(
              Localization.t('profile.score_display', args: [score.toString()]),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: successRate, backgroundColor: Colors.grey.shade800, color: color, minHeight: 8),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Localization.t('profile.correct_label', args: [correct]), style: const TextStyle(color: Colors.green, fontSize: 14)),
            Text(Localization.t('profile.wrong_label', args: [wrong]), style: const TextStyle(color: Colors.red, fontSize: 14)),
            Text(Localization.t('profile.success_label', args: [(successRate * 100).toStringAsFixed(1)]), style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}