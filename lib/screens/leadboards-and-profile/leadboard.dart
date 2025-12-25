import 'package:geogame/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Leadboard extends StatefulWidget {
  @override
  _LeadboardState createState() => _LeadboardState();
}

class _LeadboardState extends State<Leadboard> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await fetchLeaderboardFromSupabase();
    await readFromFile((update) => setState(update));
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

  /// ✅ Supabase'den leaderboard verilerini çek
  Future<void> fetchLeaderboardFromSupabase() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Tüm kullanıcı ID'lerini ve istatistiklerini çek
      final statsResponse = await _supabase
          .from('geogame_stats')
          .select()
          .order('puan', ascending: false);

      if (statsResponse.isEmpty) {
        debugPrint('Hiç istatistik verisi bulunamadı');
        setState(() {
          users = [];
          _isLoading = false;
        });
        return;
      }

      // 2️⃣ Tüm kullanıcı ID'lerini topla
      final userIds = statsResponse.map((stat) => stat['user_id'] as String).toList();

      // 3️⃣ Tüm profilleri tek seferde çek
      final profilesResponse = await _supabase
          .from('profiles')
          .select()
          .inFilter('uid', userIds); // ✅ in_ yerine inFilter

      // 4️⃣ Profilleri Map'e çevir (hızlı erişim için)
      final profilesMap = <String, Map<String, dynamic>>{};
      for (var profile in profilesResponse) {
        profilesMap[profile['uid']] = profile;
      }

      // 5️⃣ Verileri birleştir
      List<Map<String, dynamic>> leaderboardData = statsResponse.map<Map<String, dynamic>>((stat) {
        final userId = stat['user_id'] as String;
        final profile = profilesMap[userId];

        return {
          'name': profile?['full_name'] ?? 'Anonim Oyuncu',
          'uid': userId,
          'profilurl': profile?['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',
          'puan': (stat['puan'] ?? 0) as int,
          'mesafepuan': (stat['mesafepuan'] ?? 0) as int,
          'baskentpuan': (stat['baskentpuan'] ?? 0) as int,
          'bayrakpuan': (stat['bayrakpuan'] ?? 0) as int,
          'mesafedogru': (stat['mesafedogru'] ?? 0) as int,
          'baskentdogru': (stat['baskentdogru'] ?? 0) as int,
          'bayrakdogru': (stat['bayrakdogru'] ?? 0) as int,
          'mesafeyanlis': (stat['mesafeyanlis'] ?? 0) as int,
          'baskentyanlis': (stat['baskentyanlis'] ?? 0) as int,
          'bayrakyanlis': (stat['bayrakyanlis'] ?? 0) as int,
        };
      }).toList();

      setState(() {
        users = leaderboardData;
        _isLoading = false;
      });

      debugPrint('✅ Leaderboard başarıyla yüklendi: ${users.length} kullanıcı');

    } catch (e) {
      debugPrint('❌ Leaderboard yükleme hatası: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sıralama yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getBackgroundColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Altın renk
      case 1:
        return Colors.grey[300]!; // Gümüş renk
      case 2:
        return Colors.deepOrangeAccent; // Bronz renk
      default:
        return Colors.blueAccent; // Diğerleri için standart renk
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('navigasyonbar2')),
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
            onPressed: fetchLeaderboardFromSupabase,
            tooltip: 'Yenile',
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : users.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.leaderboard, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Henüz sıralamada kimse yok',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Userprofile(
                      userindex: index,
                    ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        radius: 15,
                        backgroundColor: _getBackgroundColor(index),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          users[index]['profilurl'] ??
                              'https://geogame-cdn.keremkk.com.tr/anon.png',
                        ),
                        radius: 30,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              users[index]['name'] ?? 'Anonim Oyuncu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Puan: ${users[index]['puan'] ?? 0}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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