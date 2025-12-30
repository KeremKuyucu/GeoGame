import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Modeller ve Servisler
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';

// Widgetlar
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/profile_view_widget.dart';

// Ekranlar
import 'package:geogame/screens/auth/authpage.dart';

class Profiles extends StatefulWidget {
  const Profiles({super.key});

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;

  // Supabase'den gelen ham veriyi tutacak değişken
  Map<String, dynamic>? _userStats;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final String? currentId = AuthService.currentUserId;

    if (currentId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Veriyi Supabase'den çekiyoruz
      final data = await _supabase
          .from('leaderboard_view')
          .select()
          .eq('uid', currentId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _userStats = data;
        });
      }
    } catch (e) {
      debugPrint('❌ Profil yükleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giriş kontrolü
    if (!AuthService.isAuthenticated && !_isLoading) {
      return _buildGuestView();
    }

    // İsim ve Avatar'ı AppState'den (Auth), diğerlerini DB'den alıyoruz
    // Eğer DB verisi henüz gelmediyse varsayılan değerler kullanıyoruz
    final String name = AppState.user.name.isNotEmpty ? AppState.user.name : Localization.t('settings.guest');
    final String avatarUrl = AppState.user.avatarUrl; // Auth'dan gelen güncel avatar
    final int totalScore = _userStats != null ? (_userStats!['total_score'] ?? 0) : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localization.t('profile.title').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.teal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: fetchUserProfile,
          ),
        ],
      ),
      drawer: const DrawerWidget(),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProfileViewWidget(
        name: name,
        avatarUrl: avatarUrl,
        totalScore: totalScore,
        // EN ÖNEMLİ KISIM:
        // Veriyi parçalamadan, doğrudan Supabase Map'ini veriyoruz.
        // Eğer veri yoksa boş bir map {} gönderiyoruz.
        stats: _userStats ?? {},
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localization.t('profile.title').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      drawer: const DrawerWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Localization.t("auth.login_required"),
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: Text(Localization.t("auth.login")),
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
                        setState(() => fetchUserProfile());
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
}