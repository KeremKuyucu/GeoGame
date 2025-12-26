import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:geogame/services/localization_service.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/bottomBar.dart';
import 'package:geogame/models/drawer_widget.dart';

import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/profiles/profiles.dart';
import 'package:geogame/screens/settings/settings.dart';
import 'package:geogame/screens/leadboards-and-profile/userprofile.dart';

class Leadboard extends StatefulWidget {
  @override
  _LeadboardState createState() => _LeadboardState();
}

class _LeadboardState extends State<Leadboard> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }


  /// ✅ Supabase'den leaderboard verilerini çek (Optimize Edildi)
  Future<void> _fetchLeaderboard() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1️⃣ İstatistikleri Puan Sırasına Göre Çek
      // DB sütunu 'puan' olduğu için sıralamayı buna göre yapıyoruz.
      final statsResponse = await _supabase
          .from('geogame_stats')
          .select()
          .order('totalScore', ascending: false)
          .limit(100); // Performans için ilk 100 kişiyi çekmek mantıklıdır

      if (statsResponse.isEmpty) {
        setState(() {
          _users = [];
          _isLoading = false;
        });
        return;
      }

      // 2️⃣ İlgili Kullanıcıların Profillerini Çek
      final userIds = statsResponse.map((stat) => stat['user_id'] as String).toList();

      final profilesResponse = await _supabase
          .from('profiles')
          .select()
          .inFilter('uid', userIds);

      // Profilleri hızlı erişim için Map'e çevir
      final profilesMap = {
        for (var profile in profilesResponse) profile['uid']: profile
      };

      // 3️⃣ Verileri Birleştir ve Formatla
      List<Map<String, dynamic>> leaderboardData = statsResponse.map<Map<String, dynamic>>((stat) {
        final userId = stat['user_id'] as String;
        final profile = profilesMap[userId];

        return {
          'uid': userId,
          'name': profile?['full_name'] ?? 'Anonim Oyuncu',
          'avatar_url': profile?['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',

          'totalScore': (stat['totalScore'] ?? 0) as int,

          'distanceScore': (stat['distanceScore'] ?? 0) as int,
          'distanceCorrectCount': (stat['distanceCorrectCount'] ?? 0) as int,
          'distanceWrongCount': (stat['distanceWrongCount'] ?? 0) as int,

          'flagScore': (stat['flagScore'] ?? 0) as int,
          'flagCorrectCount': (stat['flagCorrectCount'] ?? 0) as int,
          'flagWrongCount': (stat['flagWrongCount'] ?? 0) as int,

          'capitalScore': (stat['capitalScore'] ?? 0) as int,
          'capitalCorrectCount': (stat['capitalCorrectCount'] ?? 0) as int,
          'capitalWrongCount': (stat['capitalWrongCount'] ?? 0) as int,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _users = leaderboardData;
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint('❌ Leaderboard Hatası: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sıralama yüklenemedi. Lütfen internetinizi kontrol edin.')),
        );
      }
    }
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFFFD700); // Altın
      case 1: return const Color(0xFFC0C0C0); // Gümüş
      case 2: return const Color(0xFFCD7F32); // Bronz
      default: return Colors.blueAccent.withValues(alpha: 0.1);
    }
  }

  Color _getRankTextColor(int index) {
    if (index < 3) return Colors.white;
    return Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('navigasyonbar2')), // "Sıralama"
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLeaderboard,
            tooltip: Localization.get("refresh"),
          ),
        ],
      ),
      drawer: const DrawerWidget(), // const eklendi
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator( // Aşağı çekince yenileme özelliği
        onRefresh: _fetchLeaderboard,
        child: _users.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.leaderboard_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Henüz sıralama verisi yok',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Userprofile(
                        user: _users[index],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      // Sıralama Numarası
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getRankColor(index),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getRankTextColor(index),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Profil Resmi
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(user['avatar_url']),
                      ),
                      const SizedBox(width: 16),

                      // İsim ve Puan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${user['totalScore']} Puan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: AppState.selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        items: navBarItems,

        // ✅ Tüm mantık burada
        onTap: (index) {
          // 1. Zaten aynı sayfadaysak HİÇBİR ŞEY YAPMA (Buradan çık)
          if (AppState.selectedIndex == index) return;

          // 2. Değilsek, seçili indexi güncelle (Rengi değiştirir)
          setState(() {
            AppState.selectedIndex = index;
          });

          // 3. Hangi sayfaya gidileceğini belirle
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

          // 4. Sayfaya git (Animasyonsuz geçiş en iyisidir)
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
}