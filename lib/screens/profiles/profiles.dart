import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Modeller ve Servisler
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';

// Widgetlar
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/profile_view_widget.dart'; // ✅ Yeni widget'ı import ettik

// Ekranlar
import 'package:geogame/screens/auth/authpage.dart';

class Profiles extends StatefulWidget {
  const Profiles({super.key});

  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // Profil verilerini çekme fonksiyonu (Aynen kalıyor)
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giriş yapmamışsa misafir ekranı göster
    if (!AuthService.isAuthenticated && !_isLoading) {
      return _buildGuestView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localization.t('profile.title').toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.teal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded),
            onPressed: fetchUserProfile,
          ),
        ],
      ),
      drawer: const DrawerWidget(),

      // ✅ İŞTE SİHİR BURADA:
      // Tüm o karmaşık Column ve Card yapılarını sildik.
      // Yerine sadece tek bir satır widget koyduk.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProfileViewWidget(
        name: AppState.user.name,
        avatarUrl: AppState.user.avatarUrl,
        totalScore: AppState.stats.totalScore,
        // AppState verilerini Widget'ın istediği Map formatına çeviriyoruz:
        stats: {
          'distanceScore': AppState.stats.distanceScore,
          'distanceCorrectCount': AppState.stats.distanceCorrectCount,
          'distanceWrongCount': AppState.stats.distanceWrongCount,

          'flagScore': AppState.stats.flagScore,
          'flagCorrectCount': AppState.stats.flagCorrectCount,
          'flagWrongCount': AppState.stats.flagWrongCount,

          'capitalScore': AppState.stats.capitalScore,
          'capitalCorrectCount': AppState.stats.capitalCorrectCount,
          'capitalWrongCount': AppState.stats.capitalWrongCount,
        },
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