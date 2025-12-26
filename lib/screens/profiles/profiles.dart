import 'package:geogame/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/bottomBar.dart';
import 'package:geogame/models/drawer_widget.dart';

import 'package:geogame/services/auth_service.dart';
import 'package:geogame/screens/auth/authpage.dart';

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
    await fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final String? currentId = AuthService.currentUserId;

    if (currentId == null) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('⚠️ Kullanıcı giriş yapmamış');
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
          AppState.stats.distanceScore  = (statsData['distanceScore'] ?? 0) as int;
          AppState.stats.flagScore = (statsData['flagScore'] ?? 0) as int;
          AppState.stats.capitalScore  = (statsData['capitalScore'] ?? 0) as int;

          AppState.stats.distanceCorrectCount  = (statsData['distanceCorrectCount'] ?? 0) as int;
          AppState.stats.distanceWrongCount  = (statsData['distanceWrongCount'] ?? 0) as int;
          AppState.stats.flagCorrectCount  = (statsData['flagCorrectCount'] ?? 0) as int;
          AppState.stats.flagWrongCount  = (statsData['flagWrongCount'] ?? 0) as int;
          AppState.stats.capitalCorrectCount  = (statsData['capitalCorrectCount'] ?? 0) as int;
          AppState.stats.capitalWrongCount  = (statsData['capitalWrongCount'] ?? 0) as int;
        });
      }

      debugPrint('✅ Profil başarıyla yüklendi');

    } catch (e) {
      debugPrint('❌ Profil yükleme hatası: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectIndex(int index) async {
    setState(() {
      AppState.selectedIndex = index;
    });
    if (AppState.selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else if (AppState.selectedIndex == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (AppState.selectedIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (AppState.selectedIndex == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('navigasyonbar3')),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchUserProfile,
            tooltip: Localization.get("refresh"),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : !AuthService.isAuthenticated
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              Localization.get("giris_yap_mesaj"),
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      onLoginSuccess: () {
                        setState(() {
                          _initializeGame();
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      )
          : Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 15.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
        color: Colors.grey.shade800,
        child: Container(
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil başlığı ve profil resmi
                Row(
                  children: [
                    // Profil Resmi
                    CircleAvatar(
                      radius: 35.0,
                      backgroundImage: NetworkImage(AppState.user.avatarUrl),
                      backgroundColor: Colors.grey,
                    ),
                    SizedBox(width: 16.0),
                    // Kullanıcı adı
                    Expanded(
                      child: Text(
                        AppState.user.name,
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                Divider(
                  color: Colors.white.withOpacity(0.6),
                  thickness: 1.2,
                ),
                SizedBox(height: 10.0),

                // Kullanıcı puanı
                Text(
                  '${Localization.get('profil1')} $AppState.stats.totalScore',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10.0),

                // Mesafe puan doğru / yanlış
                Divider(
                  color: Colors.white.withOpacity(0.6),
                  thickness: 1.2,
                ),
                Text(
                  '${Localization.get('profil2')} $AppState.stats.distanceScore',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil3')} $AppState.stats.distanceCorrectCount',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil4')} $AppState.stats.distanceWrongCount',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10.0),
                Divider(
                  color: Colors.white.withOpacity(0.6),
                  thickness: 1.2,
                ),
                // Bayrak puan doğru / yanlış
                Text(
                  '${Localization.get('profil5')} $AppState.stats.flagScore',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil6')} $AppState.stats.flagCorrectCount',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil7')} $AppState.stats.flagWrongCount',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10.0),
                Divider(
                  color: Colors.white.withOpacity(0.6),
                  thickness: 1.2,
                ),
                // Başkent puan doğru / yanlış
                Text(
                  '${Localization.get('profil8')} $AppState.stats.capitalScore',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil9')} $AppState.stats.capitalCorrectCount',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil10')} $AppState.stats.capitalWrongCount',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: AppState.selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            AppState.selectedIndex = index;
          });
          _selectIndex(AppState.selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}