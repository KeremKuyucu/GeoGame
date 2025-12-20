import 'package:geogame/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    await readFromFile((update) => setState(update));
  }

  /// ✅ Kullanıcının kendi profilini Supabase'den çek
  Future<void> fetchUserProfile() async {
    if (uid.isEmpty) {
      setState(() => _isLoading = false);
      debugPrint('⚠️ Kullanıcı giriş yapmamış');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Profiles tablosundan kullanıcı bilgilerini çek
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (profileData != null) {
        setState(() {
          name = profileData['full_name'] ?? 'Anonim Oyuncu';
          profilurl = profileData['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';
        });
      }

      // 2️⃣ geogame_stats tablosundan istatistikleri çek
      final statsData = await _supabase
          .from('geogame_stats')
          .select()
          .eq('user_id', uid)
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

      // 3️⃣ Verileri locale kaydet
      await writeToFile();

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
      selectedIndex = index;
    });
    if (selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 3) {
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
        title: Text(Yazi.get('navigasyonbar4')),
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
          : uid.isEmpty
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
                      backgroundImage: NetworkImage(profilurl),
                      backgroundColor: Colors.grey,
                    ),
                    SizedBox(width: 16.0),
                    // Kullanıcı adı
                    Expanded(
                      child: Text(
                        name,
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
                  '${Yazi.get('profil1')} $toplampuan',
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
                  '${Yazi.get('profil2')} $mesafepuan',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Yazi.get('profil3')} $mesafedogru',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Yazi.get('profil4')} $mesafeyanlis',
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
                  '${Yazi.get('profil5')} $bayrakpuan',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Yazi.get('profil6')} $bayrakdogru',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Yazi.get('profil7')} $bayrakyanlis',
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
                  '${Yazi.get('profil8')} $baskentpuan',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Yazi.get('profil9')} $baskentdogru',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${Yazi.get('profil10')} $baskentyanlis',
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
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}