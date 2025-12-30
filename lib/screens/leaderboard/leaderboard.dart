import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/services/localization_service.dart';
// Userprofile importunu kaldırdık
import 'package:geogame/widgets/profile_view_widget.dart'; // Bunu eklemeyi unutma

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
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
      final response = await _supabase
          .from('leaderboard_view')
          .select()
          .limit(100);

      if (response.isEmpty) {
        if (mounted) {
          setState(() {
            _users = [];
            _isLoading = false;
          });
        }
        return;
      }

      final List<Map<String, dynamic>> leaderboardData = (response as List).map<Map<String, dynamic>>((row) {
        return {
          'uid': row['uid'] ?? '',
          'name': row['full_name'] ?? 'Guest',
          'avatar_url': row['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',

          // Genel Skorlar
          'total_score': (row['total_score'] ?? 0) as int, // DİKKAT: Anahtar ismi total_score
          'total_correct': (row['total_correct'] ?? 0) as int,
          'total_wrong': (row['total_wrong'] ?? 0) as int,

          // Mod Verileri
          'score_flag': (row['score_flag'] ?? 0) as int,
          'flag_correct': (row['flag_correct'] ?? 0) as int,
          'flag_wrong': (row['flag_wrong'] ?? 0) as int,

          'score_capital': (row['score_capital'] ?? 0) as int,
          'capital_correct': (row['capital_correct'] ?? 0) as int,
          'capital_wrong': (row['capital_wrong'] ?? 0) as int,

          'score_distance': (row['score_distance'] ?? 0) as int,
          'distance_correct': (row['distance_correct'] ?? 0) as int,
          'distance_wrong': (row['distance_wrong'] ?? 0) as int,

          'score_borderline': (row['score_borderline'] ?? 0) as int,
          'borderline_correct': (row['borderline_correct'] ?? 0) as int,
          'borderline_wrong': (row['borderline_wrong'] ?? 0) as int,
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
      case 0: return const Color(0xFFFFD700);
      case 1: return const Color(0xFFC0C0C0);
      case 2: return const Color(0xFFCD7F32);
      default: return Colors.blueAccent.withValues(alpha: 0.1);
    }
  }

  Color _getRankTextColor(int index) {
    if (index < 3) return Colors.white;
    return Colors.blueAccent;
  }

  // --- YENİ FONKSİYON: Profile Git ---
  // Tekrarlanan kodu engellemek için navigasyonu buraya aldık
  void _navigateToProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(user['name'] ?? ''),
            centerTitle: true,
          ),
          // DrawerWidget'ı burada kullanmıyoruz çünkü geri butonu olmalı
          body: ProfileViewWidget(
            name: user['name'] ?? Localization.t('settings.guest'),
            avatarUrl: user['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',
            totalScore: user['total_score'] ?? 0,
            stats: user,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localization.t('leaderboard.title').toUpperCase(),
          style: const TextStyle(
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
            : CustomScrollView(
          slivers: [
            if (_users.length >= 3)
              SliverToBoxAdapter(child: _buildPodium()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _podiumItem(1, 100), // 2. Sıra
          _podiumItem(0, 130), // 1. Sıra
          _podiumItem(2, 90),  // 3. Sıra
        ],
      ),
    );
  }

  Widget _podiumItem(int index, double height) {
    final user = _users[index];
    final color = _getRankColor(index);

    return GestureDetector(
      onTap: () => _navigateToProfile(user), // YENİ YÖNLENDİRME
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
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
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
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${user['total_score']} P', // DÜZELTİLDİ: totalScore -> total_score
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(int index) {
    final user = _users[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: () => _navigateToProfile(user), // YENİ YÖNLENDİRME
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
            // DÜZELTİLDİ: totalScore -> total_score
            Text('${user['total_score']} ${Localization.t('leaderboard.score')}', style: const TextStyle(fontSize: 12)),
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