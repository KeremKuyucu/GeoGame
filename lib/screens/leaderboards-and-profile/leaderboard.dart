import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/widgets/drawer_widget.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/screens/leaderboards-and-profile/userprofile.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

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
          'name': profile?['full_name'] ?? 'Guest',
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
      debugPrint('❌ Leaderboard Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Localization.t('leaderboard.load_error'))),
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
        title: Text(
          Localization.t('leaderboard.title').toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.pink,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchLeaderboard,
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchLeaderboard,
        child: _users.isEmpty
            ? _buildEmptyState()
            : CustomScrollView( // Podium + Listeyi birleştirmek için en iyisi
          slivers: [
            if (_users.length >= 3)
              SliverToBoxAdapter(child: _buildPodium()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    // Eğer podyum varsa, listeden ilk 3'ü atla
                    final listIndex = _users.length >= 3 ? index + 3 : index;
                    if (listIndex >= _users.length) return null;
                    return _buildUserCard(listIndex);
                  },
                  childCount: _users.length >= 3 ? _users.length - 3 : _users.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _podiumItem(1, 100), // 2. Sıra
          _podiumItem(0, 130), // 1. Sıra (En büyük)
          _podiumItem(2, 90),  // 3. Sıra
        ],
      ),
    );
  }

  Widget _podiumItem(int index, double height) {
    final user = _users[index];
    final color = _getRankColor(index);

    // ✅ DÜZELTME: GestureDetector ile sarmaladık
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Userprofile(user: user),
          ),
        );
      },
      // Tıklama efektinin daha belirgin olması için 'Behavior' ekleyebilirsin
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                  // Avatarın arkasına gölge ekleyerek tıklanabilir hissi verelim
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: height / 2.5,
                  backgroundImage: NetworkImage(user['avatar_url']),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(Icons.emoji_events, size: 16, color: _getRankTextColor(index)),
              ),
            ],
          ),
          Text(
            user['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            overflow: TextOverflow.ellipsis, // İsim uzunsa taşmasın
          ),
          Text(
            '${user['totalScore']} P',
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Normal Liste Kartı
  Widget _buildUserCard(int index) {
    final user = _users[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Userprofile(user: user))),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey.shade400, fontSize: 16)),
            const SizedBox(width: 15),
            CircleAvatar(backgroundImage: NetworkImage(user['avatar_url'])),
          ],
        ),
        title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            const Icon(Icons.star, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text('${user['totalScore']} ${Localization.t('leaderboard.score')}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.leaderboard_rounded, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(Localization.t('leaderboard.no_data'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}