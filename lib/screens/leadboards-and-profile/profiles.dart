import 'package:geogame/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/app_context.dart';
import '../../data/bottomBar.dart';
import '../../services/auth_service.dart';
import '../auth/authpage.dart';

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
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('uid', currentId)
          .maybeSingle();

      final statsData = await _supabase
          .from('geogame_stats')
          .select()
          .eq('user_id', currentId)
          .maybeSingle();

      if (statsData != null) {
        setState(() {
          toplampuan = (statsData['puan'] ?? 0) as int;
          mesafepuan = (statsData['mesafepuan'] ?? 0) as int;
          bayrakpuan = (statsData['bayrakpuan'] ?? 0) as int;
          baskentpuan = (statsData['baskentpuan'] ?? 0) as int;

          mesafedogru = (statsData['mesafedogru'] ?? 0) as int;
          mesafeyanlis = (statsData['mesafeyanlis'] ?? 0) as int;
          bayrakdogru = (statsData['bayrakdogru'] ?? 0) as int;
          bayrakyanlis = (statsData['bayrakyanlis'] ?? 0) as int;
          baskentdogru = (statsData['baskentdogru'] ?? 0) as int;
          baskentyanlis = (statsData['baskentyanlis'] ?? 0) as int;
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
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
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
        title: Text(Localization.get('navigasyonbar4')),
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
            tooltip: 'Yenile',
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
              'Giriş yapmanız gerekiyor',
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
                  '${Localization.get('profil1')} $toplampuan',
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
                  '${Localization.get('profil2')} $mesafepuan',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil3')} $mesafedogru',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil4')} $mesafeyanlis',
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
                  '${Localization.get('profil5')} $bayrakpuan',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil6')} $bayrakdogru',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil7')} $bayrakyanlis',
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
                  '${Localization.get('profil8')} $baskentpuan',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil9')} $baskentdogru',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Localization.get('profil10')} $baskentyanlis',
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