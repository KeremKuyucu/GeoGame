import 'package:flutter/material.dart';
import 'package:geogame/models/drawer_widget.dart';
import 'package:geogame/services/localization_service.dart';

class Userprofile extends StatefulWidget {
  // Leadboard'dan gelen kullanıcı verisi
  final Map<String, dynamic> user;

  const Userprofile({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<Userprofile> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    // Resim anahtarı bazen 'profilurl' bazen 'avatar_url' gelebilir, kontrol edelim
    final String avatarUrl = user['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';

    return Scaffold(
      appBar: AppBar(
        title: Text(user['name'] ?? 'Profil'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Üst Kart (Avatar + İsim + Toplam Puan)
            _buildHeaderCard(user, avatarUrl),

            const SizedBox(height: 20),

            // 2. İstatistik Kartı (Detaylı)
            _buildDetailedStatsCard(user),
          ],
        ),
      ),
    );
  }

  /// 🏆 Üst Kart Tasarımı
  Widget _buildHeaderCard(Map<String, dynamic> user, String avatarUrl) {
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
                    user['name'] ?? 'Anonim',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${Localization.get('toplam_puan')}: ${user['totalScore'] ?? 0}',
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

  /// 📊 Alt Kart: Detaylı İstatistikler
  Widget _buildDetailedStatsCard(Map<String, dynamic> user) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              Localization.get('oyun_istatistikleri'), // "Oyun İstatistikleri"
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 1. Mesafe
            _buildGameStatSection(
              title: Localization.get('oyun_mesafe'),
              icon: Icons.map,
              color: Colors.tealAccent,
              score: user['distanceScore'] ?? 0,
              correct: user['distanceCorrectCount'] ?? 0,
              wrong: user['distanceWrongCount'] ?? 0,
            ),
            const Divider(color: Colors.white24, height: 30),

            // 2. Bayrak
            _buildGameStatSection(
              title: Localization.get('oyun_bayrak'),
              icon: Icons.flag,
              color: Colors.orangeAccent,
              score: user['flagScore'] ?? 0,
              correct: user['flagCorrectCount'] ?? 0,
              wrong: user['flagWrongCount'] ?? 0,
            ),
            const Divider(color: Colors.white24, height: 30),

            // 3. Başkent
            _buildGameStatSection(
              title: Localization.get('oyun_baskent'),
              icon: Icons.location_city,
              color: Colors.purpleAccent,
              score: user['capitalScore'] ?? 0,
              correct: user['capitalCorrectCount'] ?? 0,
              wrong: user['capitalWrongCount'] ?? 0,
            ),
          ],
        ),
      ),
    );
  }

  /// 🧩 Tekrar Eden Bölüm (Progress Bar'lı)
  Widget _buildGameStatSection({
    required String title,
    required IconData icon,
    required Color color,
    required int score,
    required int correct,
    required int wrong,
  }) {
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
                Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(
              '$score ${Localization.get('puan')}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: successRate,
            backgroundColor: Colors.grey.shade800,
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${Localization.get('dogru')}: $correct', style: const TextStyle(color: Colors.green, fontSize: 14)),
            Text('${Localization.get('yanlis')}: $wrong', style: const TextStyle(color: Colors.red, fontSize: 14)),
            Text('${Localization.get('basari_orani')}: %${(successRate * 100).toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}