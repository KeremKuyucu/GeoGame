import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/bottomBar.dart';
import 'package:geogame/models/drawer_widget.dart';

import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';

import 'package:geogame/screens/auth/authpage.dart';
import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/leadboards-and-profile/leadboard.dart';
import 'package:geogame/screens/settings/settings.dart';


class Profiles extends StatefulWidget {
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Önce oturum kontrolü, sonra veri çekme
    await AuthService.checkSession();
    await fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final String? currentId = AuthService.currentUserId;

    if (currentId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final statsData = await _supabase
          .from('geogame_stats')
          .select()
          .eq('user_id', currentId)
          .maybeSingle();

      if (statsData != null) {
        setState(() {
          AppState.stats = GameStats.fromMap(statsData);
        });
      }
      debugPrint('✅ Profil verileri güncellendi.');

    } catch (e) {
      debugPrint('❌ Profil yükleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giriş yapmamış kullanıcı ekranı
    if (!AuthService.isAuthenticated && !_isLoading) {
      return _buildGuestView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('navigasyonbar3')), // "Profil"
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUserProfile,
            tooltip: Localization.get("refresh"),
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Kart: Kullanıcı Bilgisi ve Toplam Puan
            _buildHeaderCard(),

            const SizedBox(height: 20),

            // 2. Kart: Detaylı Oyun İstatistikleri
            _buildDetailedStatsCard(),
          ],
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: AppState.selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        items: navBarItems,
        onTap: (index) {
          if (AppState.selectedIndex == index) return;

          setState(() {
            AppState.selectedIndex = index;
          });

          Widget page;
          switch (index) {
            case 0:
              page = MainScreen();
              break;
            case 1:
              page = Leadboard();
              break;
            case 2:
              page = Profiles();
              break;
            case 3:
              page = SettingsPage();
              break;
            default:
              return;
          }

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => page,
              transitionDuration: Duration.zero, // Anında geçiş
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }

  /// 👤 Giriş Yapmamış Kullanıcı Görünümü
  Widget _buildGuestView() {
    return Scaffold(
      appBar: AppBar(title: Text(Localization.get('navigasyonbar3'))),
      drawer: const DrawerWidget(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: AppState.selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        items: navBarItems,
        onTap: (index) {
          if (AppState.selectedIndex == index) return;
          setState(() {
            AppState.selectedIndex = index;
          });

          Widget page;
          switch (index) {
            case 0:
              page = MainScreen();
              break;
            case 1:
              page = Leadboard();
              break;
            case 2:
              page = Profiles();
              break;
            case 3:
              page = SettingsPage();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => page,
              transitionDuration: Duration.zero, // Anında geçiş
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Localization.get("giris_yap_mesaj"),
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Giriş Yap / Kayıt Ol'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      onLoginSuccess: () {
                        setState(() => _initializeGame());
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🏆 Üst Kart: Avatar, İsim, Toplam Puan
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
                backgroundImage: NetworkImage(AppState.user.avatarUrl),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppState.user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        '${Localization.get('toplam_puan')}: ${AppState.stats.totalScore}',
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
  Widget _buildDetailedStatsCard() {
    final stats = AppState.stats;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Oyun İstatistikleri",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 1. Mesafe Oyunu
            _buildGameStatSection(
              title: Localization.get('oyun_mesafe'),
              icon: Icons.map,
              color: Colors.tealAccent,
              score: stats.distanceScore,
              correct: stats.distanceCorrectCount,
              wrong: stats.distanceWrongCount,
            ),
            const Divider(color: Colors.white24, height: 30),

            // 2. Bayrak Oyunu
            _buildGameStatSection(
              title: Localization.get('oyun_bayrak'),
              icon: Icons.flag,
              color: Colors.orangeAccent,
              score: stats.flagScore,
              correct: stats.flagCorrectCount,
              wrong: stats.flagWrongCount,
            ),
            const Divider(color: Colors.white24, height: 30),

            // 3. Başkent Oyunu
            _buildGameStatSection(
              title: Localization.get('oyun_baskent'),
              icon: Icons.location_city,
              color: Colors.purpleAccent,
              score: stats.capitalScore,
              correct: stats.capitalCorrectCount,
              wrong: stats.capitalWrongCount,
            ),
          ],
        ),
      ),
    );
  }

  /// 🧩 Tekrar Eden İstatistik Satırı Widget'ı
  Widget _buildGameStatSection({
    required String title,
    required IconData icon,
    required Color color,
    required int score,
    required int correct,
    required int wrong,
  }) {
    // Başarı Oranı Hesaplama
    int total = correct + wrong;
    double successRate = total > 0 ? (correct / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve Puan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              '$score ${Localization.get('puan')}', // "1500 Puan"
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // İlerleme Çubuğu (Başarı Oranı)
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

        // Detaylar (Doğru / Yanlış / Oran)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${Localization.get('dogru')}: $correct',
              style: const TextStyle(color: Colors.green, fontSize: 14),
            ),
            Text(
              '${Localization.get('yanlis')}: $wrong',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            Text(
              '${Localization.get('basari_orani')}: %${(successRate * 100).toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}